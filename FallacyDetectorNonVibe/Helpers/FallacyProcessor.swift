//
//  FallacyProcessor.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

struct FallacyProcessor {
    let promptSender: PromptSender

    /// Analyzes the input text and returns the parsed logical fallacy results.
    /// - Parameter text: The input text to analyze.
    /// - Returns: An array of LogicalFallacy objects found in the text.
    func fetch(text: String) async -> [Fallacy]? {
        let prompt = PromptGenerator.generatePrompt(for: text)
        do {
            if let responseString = try await promptSender.sendPrompt(prompt) {
                let fallacies = ResponseParser.parseJSON(jsonString: responseString)
                return fallacies
            }
        } catch {
            // Handle the error here (e.g., show an alert, log, or store the error)
            AppLogger.fetch.error("Prompt sending failed: \(error.localizedDescription)")
        }
        return nil
    }
}
