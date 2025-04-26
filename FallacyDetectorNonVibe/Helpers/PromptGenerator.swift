//
//  PromptGenerator.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

// PromptGenerator.swift

import Foundation

/// A utility for generating prompts to detect logical fallacies in a given input string.
/// The generated prompt instructs a language model to analyze the text, identify logical fallacies,
/// and return a structured JSON response with details for each fallacy found.
struct PromptGenerator {
    
    /// Wraps the input text in a detailed prompt for logical fallacy detection.
    /// - Parameter input: The user-provided text to analyze.
    /// - Returns: A complete prompt string to send to an LLM.
    static func generatePrompt(for input: String) -> String {
        """
        You are an expert in argument analysis and logical reasoning.

        Your task is to review the following text and identify any logical fallacies present.
        For each fallacy you find, return a JSON object with the following fields:
        
        - "fallacy": The name of the logical fallacy.
        - "originalText": The specific sentence(s) or phrase(s) in the input text where the fallacy occurs.
        - "avoidance": Advice on how the fallacy could have been avoided in the original argument.
        - "counter": Suggestions for how someone could counter this fallacy in a debate.
        - "reference": A link to a Wikipedia article (or another reputable online source if Wikipedia does not cover the fallacy) explaining the fallacy.

        If no fallacies are found, return an empty JSON array.

        Respond ONLY with the JSON array as described above. Do not change any characters, spacing, or other aspects of the input string when forming the "oritingalText" strings - return them exactly as they were input. For each fallacy, there must be accompanying fields for originalText, avoidance, counter, and reference.

        Here is the text to analyze:
        \"\"\"
        \(input)
        \"\"\"
        """
    }
}
