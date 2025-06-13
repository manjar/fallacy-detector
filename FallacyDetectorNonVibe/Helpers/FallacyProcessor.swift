//
//  FallacyProcessor.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//
import Foundation
import FoundationModels
import SwiftData

@MainActor
struct FallacyProcessor {
    let modelContext: ModelContext
    
    func createItemWithInputText(_ inputText: String) async -> Void {
        let itemID: String = await MainActor.run {
            let newItem = Item(timestamp: Date(), inputText: inputText)
            newItem.analysisState = .inProgress
            modelContext.insert(newItem)
            return newItem.id
        }
        await update(itemWithUUIDString: itemID, withInputText: inputText)
        try? modelContext.save()
    }
    
    func reAnalyzeItem(_ item: Item) async -> Void {
        await update(itemWithUUIDString: item.id, withInputText: item.inputText)
    }
    
    func update(itemWithUUIDString itemID: String, withInputText inputText: String) async -> Void {
        let session = LanguageModelSession()
        do {
            let generatedItem = try await session.respond(to: PromptGenerator.generatePrompt(for: inputText), generating: GenerableItem.self).content
            let item = generatedItem.toModel(id: UUID().uuidString, inputText: inputText)
            print("Generated an item with id: \(item.id)")
            if let itemToUpdate = try? fetchItem(by: itemID, context: modelContext) {
                itemToUpdate.analysisState = .inProgress
            }
            await MainActor.run {
                do {
                    if let itemToUpdate = try fetchItem(by: itemID, context: modelContext) {
                        itemToUpdate.fallacyInstances = item.fallacyInstances
                        itemToUpdate.analysisState = .completed
                    }
                } catch {
                    AppLogger.fetch.error("Failed to fetch item: \(error.localizedDescription)")
                }
            }
        } catch {
            
        }
        
        func createItemFromInputText(_ inputText: String) async {
            let session = LanguageModelSession()
            do {
                let generatedItem = try await session.respond(to: PromptGenerator.generatePrompt(for: inputText), generating: GenerableItem.self).content
                let item = generatedItem.toModel(id: UUID().uuidString, inputText: inputText)
                print("Generated an item with id: \(item.id)")
            } catch {
                AppLogger.fetch.error("Prompt sending failed: \(error.localizedDescription)")
            }
        }
        
        func fetchItem(by id: String, context: ModelContext) throws -> Item? {
            let descriptor = FetchDescriptor<Item>(
                predicate: #Predicate { $0.id == id }
            )
            return try context.fetch(descriptor).first
        }
    }
}
