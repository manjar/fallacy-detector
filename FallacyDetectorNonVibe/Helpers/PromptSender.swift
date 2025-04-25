//
//  PromptSender.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

// GeminiPromptSender.swift

import Foundation
import GoogleGenerativeAI

protocol PromptSender {
    /// Sends a prompt string and returns the LLM's response as a string (typically JSON).
    func sendPrompt(_ prompt: String) async throws -> String?
}

extension PromptSender {
    func logPrompt(_ prompt: String) {
        print(">>> Sending prompt: \(prompt)")
    }
}

class GeminiPromptSender: PromptSender {
    private let model: GenerativeModel

    init() {
        // Initialize the model with your API key and preferred Gemini model.
        self.model = GenerativeModel(
            name: "gemini-1.5-pro-latest", // or "gemini-1.5-flash" for the latest model[5][6]
            apiKey: APIKey.gemini.value
        )
    }

    /// Sends a prompt string to the Gemini API and prints the response.
    func sendPrompt(_ prompt: String) async throws -> String? {
        do {
            print(">>> Sending prompt: \(prompt)")
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                print("Gemini response: \(text)")
                return text
            } else {
                print("No text response received.")
            }
        } catch {
            print("Error sending prompt to Gemini: \(error)")
        }
        return nil
    }
}

class OpenAIPromptSender: PromptSender {
    private let apiKey = APIKey.openAI.value

    func sendPrompt(_ prompt: String) async throws -> String? {
        logPrompt(prompt)
        // Compose request
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Send request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            // Try to parse the JSON
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let json = jsonObject as? [String: Any] else {
                print("Failed to cast JSON to [String: Any]")
                return ""
            }

            // Extract and return content
            if let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            } else {
                print("Unexpected JSON structure: \(json)")
                return ""
            }

        } catch {
            print("Error occurred: \(error.localizedDescription)")
            return ""
        }
    }
}

