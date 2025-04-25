//
//  ResponseParser.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

// LogicalFallacyResponse.swift

import Foundation

/// Represents a single logical fallacy found in the input text.
struct Fallacy: Codable {
    let fallacy: String
    let location: String
    let avoidance: String
    let counter: String
    let reference: String
}

/// Parses the JSON response from the LLM into an array of LogicalFallacy objects.
struct ResponseParser {
    /// Parses a JSON string into an array of LogicalFallacy objects.
    /// - Parameter jsonString: The JSON string returned by the LLM.
    /// - Returns: An array of LogicalFallacy objects, or an empty array if parsing fails.
    static func parse(jsonString: String) -> [Fallacy] {
        print("Attempting to parse JSON string: <<\(jsonString)>>")
        guard let data = jsonString.data(using: .utf8) else { return [] }
        do {
            return try JSONDecoder().decode([Fallacy].self, from: data)
        } catch {
            print("Failed to decode LogicalFallacy JSON: \(error)")
            return []
        }
    }
}
