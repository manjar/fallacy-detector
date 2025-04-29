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

struct ResponseParser {
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
