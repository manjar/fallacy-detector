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
    func analyze(text: String) async -> [Fallacy]? {
        let prompt = PromptGenerator.generatePrompt(for: text)
        do {
            let responseString = try await promptSender.sendPrompt(prompt)
            if let responseString {
                let fallacies = ResponseParser.parse(jsonString: responseString)
                return fallacies
            }
        } catch {
            // Handle the error here (e.g., show an alert, log, or store the error)
            print("Prompt sending failed: \(error)")
        }
        return nil
    }
}
