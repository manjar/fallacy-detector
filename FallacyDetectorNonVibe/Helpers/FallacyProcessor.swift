//
//  FallacyProcessor.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//
import Foundation
import SwiftData

@MainActor
struct FallacyProcessor {
    let modelContext: ModelContext
    
    func createItemWithInputText(_ inputText: String) async -> Void {
        let itemID: UUID = await MainActor.run {
            let newItem = Item(timestamp: Date(), inputText: inputText)
            newItem.analysisState = .inProgress
            modelContext.insert(newItem)
            return newItem.id
        }
        await update(itemWithUUID: itemID, withInputText: inputText)
        try? modelContext.save()
    }

    func reAnalyzeItem(_ item: Item) async -> Void {
        await update(itemWithUUID: item.id, withInputText: item.inputText)
    }
    
    func update(itemWithUUID itemID: UUID, withInputText inputText: String) async -> Void {
        let fallacies = await getFallaciesFromServiceForInputText(inputText)
        if let itemToUpdate = try? fetchItem(by: itemID, context: modelContext) {
            itemToUpdate.analysisState = .inProgress
        }
        await MainActor.run {
            do {
                if let itemToUpdate = try fetchItem(by: itemID, context: modelContext) {
                    if let fallacies {
                        itemToUpdate.saveFallacyResults(fallacies)
                        itemToUpdate.errorMessage = nil
                        itemToUpdate.analysisState = .completed
                    } else {
                        itemToUpdate.fallacyResponseJSON = nil
                        itemToUpdate.errorMessage = "No fallacies found or analysis failed."
                        itemToUpdate.analysisState = .failed
                    }
                }
            } catch {
                AppLogger.fetch.error("Failed to fetch item: \(error.localizedDescription)")
            }
        }
    }

    func getFallaciesFromServiceForInputText(_ text: String) async -> [Fallacy]? {
        let prompt = PromptGenerator.generatePrompt(for: text)
        do {
            if let promptSender = DefaultPromptSender(), let responseString = try await promptSender.sendPrompt(prompt) {
                let fallacies = ResponseParser.parseJSON(jsonString: responseString)
                return fallacies
            }
        } catch {
            AppLogger.fetch.error("Prompt sending failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    func fetchItem(by id: UUID, context: ModelContext) throws -> Item? {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
}
