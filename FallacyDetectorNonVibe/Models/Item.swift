//
//  Item.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    private(set) var id: UUID
    var timestamp: Date
    var inputText: String
    var fallacyResultsJSON: String?    // Store JSON string of fallacy results
    var errorMessage: String?          // Store error message if any
    // One-to-many relationship: an Item has many FallacyInstances
    var fallacyInstances: [FallacyInstance]

    init(timestamp: Date, inputText: String) {
        self.id = UUID()
        self.timestamp = timestamp
        self.inputText = inputText
        self.fallacyResultsJSON = nil
        self.errorMessage = nil
        self.fallacyInstances = []
    }
    
    /// Computed property to decode fallacy results from JSON string
    var fallacyResults: [Fallacy]? {
        guard let json = fallacyResultsJSON else { return nil }
        return ResponseParser.parseJSON(jsonString: json)
    }
    
    /// Helper to save fallacy results as JSON
    func saveFallacyResults(_ results: [Fallacy]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(results),
           let jsonString = String(data: data, encoding: .utf8) {
            self.fallacyResultsJSON = jsonString
            let fallacyResults = ResponseParser.parseJSON(jsonString: jsonString)
            for result in fallacyResults {
                fallacyInstances.append(FallacyInstance(originalText: result.originalText, fallacy: result.fallacy, avoidance: result.avoidance, counter: result.counter, link: URL(string: result.reference)!))
            }
        }
    }
}

@Model
final class FallacyInstance: Identifiable {
    private(set) var id: UUID
    var originalText: String
    var fallacy: String
    var avoidance: String
    var counter: String
    var link: URL

    // Relationship back to Item (optional, but recommended for bidirectionality)
    weak var item: Item?

    init(
        originalText: String,
        fallacy: String,
        avoidance: String,
        counter: String,
        link: URL,
        item: Item? = nil
    ) {
        self.id = UUID()
        self.originalText = originalText
        self.fallacy = fallacy
        self.avoidance = avoidance
        self.counter = counter
        self.link = link
        self.item = item
    }
}
