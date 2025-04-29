//
//  Item.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import Foundation
import SwiftData

enum AnalysisState: Int, Codable {
    case idle       =  5
    case inProgress = 10
    case completed  = 15
    case failed     = 20
}

@Model
final class Item: Identifiable {
    private(set) var id: UUID
    var timestamp: Date
    var inputText: String
    var analysisState: AnalysisState
    var fallacyResponseJSON: String?    // Store JSON string of fallacy results
    var errorMessage: String?          // Store error message if any
    // One-to-many relationship: an Item has many FallacyInstances
    var fallacyInstances: [FallacyInstance]

    init(timestamp: Date, inputText: String) {
        self.id = UUID()
        self.timestamp = timestamp
        self.inputText = inputText
        self.analysisState = .idle
        self.fallacyResponseJSON = nil
        self.errorMessage = nil
        self.fallacyInstances = []
    }
    
    /// Helper to save fallacy results as JSON
    func saveFallacyResults(_ results: [Fallacy]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(results),
           let jsonString = String(data: data, encoding: .utf8) {
            self.fallacyResponseJSON = jsonString
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

struct CodableItem: Codable, Identifiable {
    var id: UUID
    var timestamp: Date
    var inputText: String
    var fallacyResponseJSON: String?
    var errorMessage: String?
    var fallacyInstances: [CodableFallacyInstance]
    
    func toModel() -> Item {
        let item = Item(timestamp: self.timestamp, inputText: self.inputText)
        item.fallacyResponseJSON = self.fallacyResponseJSON
        item.errorMessage = self.errorMessage
        item.fallacyInstances = self.fallacyInstances.map { $0.toModel(item: item) }
        return item
    }
}

struct CodableFallacyInstance: Codable, Identifiable {
    var id: UUID
    var originalText: String
    var fallacy: String
    var avoidance: String
    var counter: String
    var link: String // Store as String for plist compatibility
    
    func toModel(item: Item) -> FallacyInstance {
        return FallacyInstance(
            originalText: self.originalText,
            fallacy: self.fallacy,
            avoidance: self.avoidance,
            counter: self.counter,
            link: URL(string: self.link) ?? URL(string: "https://example.com")!,
            item: item
        )
    }
}

extension Item {
    func toCodable() -> CodableItem {
        CodableItem(
            id: self.id,
            timestamp: self.timestamp,
            inputText: self.inputText,
            fallacyResponseJSON: self.fallacyResponseJSON,
            errorMessage: self.errorMessage,
            fallacyInstances: self.fallacyInstances.map { $0.toCodable() }
        )
    }
}

extension FallacyInstance {
    func toCodable() -> CodableFallacyInstance {
        CodableFallacyInstance(
            id: self.id,
            originalText: self.originalText,
            fallacy: self.fallacy,
            avoidance: self.avoidance,
            counter: self.counter,
            link: self.link.absoluteString
        )
    }
}

private let fallaciesPlistFilename = "Fallacies.plist"

private var fallaciesPlistURL: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(fallaciesPlistFilename)
}

func saveCodableItemsToPlist(_ items: [CodableItem]) throws {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml

    let data = try encoder.encode(items)
    try data.write(to: fallaciesPlistURL)
    print("Saved to \(fallaciesPlistURL.path)")
}

func loadCodableItemsFromPlist() throws -> [CodableItem] {
    let data = try Data(contentsOf: fallaciesPlistURL)
    let decoder = PropertyListDecoder()
    return try decoder.decode([CodableItem].self, from: data)
}
