//
//  Item.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var inputText: String
    var fallacyResultsJSON: String?    // Store JSON string of fallacy results
    var errorMessage: String?          // Store error message if any

    init(timestamp: Date, inputText: String) {
        self.timestamp = timestamp
        self.inputText = inputText
        self.fallacyResultsJSON = nil
        self.errorMessage = nil
    }
    
    /// Computed property to decode fallacy results from JSON string
    var fallacyResults: [Fallacy]? {
        guard let json = fallacyResultsJSON else { return nil }
        return ResponseParser.parse(jsonString: json)
    }
    
    /// Helper to save fallacy results as JSON
    func saveFallacyResults(_ results: [Fallacy]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(results),
           let jsonString = String(data: data, encoding: .utf8) {
            self.fallacyResultsJSON = jsonString
        }
    }
}
