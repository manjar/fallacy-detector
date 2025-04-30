//
//  FallacyProcessor.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//
import Foundation
import SwiftData

struct FallacyProcessor {
    let modelContext: ModelContext
    let promptSender: PromptSender = DefaultPromptSender()
    
    func createItemWithInputText(_ inputText: String) async -> Void {
        let newItem = Item(timestamp: Date(), inputText: inputText)
        await update(newItem, withInputText: inputText)
    }

    func reAnalyzeItem(_ item: Item) async -> Void {
        await update(item, withInputText: item.inputText)
    }
    
    func update(_ item: Item, withInputText: String) async -> Void {
        let fallacies = await getFallaciesFromServiceForInputText(item.inputText)
        item.analysisState = .inProgress
        let itemID = item.id
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
            if let responseString = try await promptSender.sendPrompt(prompt) {
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
