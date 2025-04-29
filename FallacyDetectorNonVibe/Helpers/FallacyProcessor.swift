//
//  FallacyProcessor.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

struct FallacyProcessor {
    let promptSender: PromptSender

    func fetch(text: String) async -> [Fallacy]? {
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
}
