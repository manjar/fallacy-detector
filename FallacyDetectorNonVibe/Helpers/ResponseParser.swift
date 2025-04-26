//
//  ResponseParser.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

// LogicalFallacyResponse.swift

import Foundation

/// Represents a single logical fallacy found in the input text.
struct Fallacy: Codable, Identifiable {
    var id: UUID = UUID()
    let fallacy: String
    let originalText: String
    let avoidance: String
    let counter: String
    let reference: String
    
    private enum CodingKeys : String, CodingKey { case fallacy, originalText, avoidance, counter, reference }
}

/// Parses the JSON response from the LLM into an array of LogicalFallacy objects.
struct ResponseParser {
    /// Parses a JSON string into an array of LogicalFallacy objects.
    /// - Parameter jsonString: The JSON string returned by the LLM.
    /// - Returns: An array of LogicalFallacy objects, or an empty array if parsing fails.
    static func parseJSON(jsonString: String) -> [Fallacy] {
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
