//
//  SampleProvider.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/26/25.
//

import Foundation
import SwiftData

@MainActor
final class SampleProvider {
    static let shared = SampleProvider()
    // Sample passages
    private let samplePassagesPlistName = "SamplePassages"
    private let samplePassagesUserDefaultsKey = "SampleProvider.LastSamplePassageIndex"
    private var samplePassages: [String] = []
    private var lastSamplePassageIndex: Int {
        get { UserDefaults.standard.integer(forKey: samplePassagesUserDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: samplePassagesUserDefaultsKey) }
    }
    // Sample analyses
    private let sampleAnalysesUserDefaultsKey = "SampleProvider.LastSampleAnalysisIndex"
    private var sampleAnalyses: [CodableItem] = []
    private var lastSampleAnalysisIndex: Int {
        get { UserDefaults.standard.integer(forKey: sampleAnalysesUserDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: sampleAnalysesUserDefaultsKey) }
    }
    
    init() {
        loadSamplePassages()
        loadSampleAnalyses()
    }
    
    func nextSamplePassage() -> String? {
        guard !samplePassages.isEmpty else { return nil }
        let nextIndex = (lastSamplePassageIndex + 1) % samplePassages.count
        lastSamplePassageIndex = nextIndex
        return samplePassages[nextIndex]
    }
    
    func nextSampleAnalysis() -> CodableItem? {
        guard !sampleAnalyses.isEmpty else { return nil }
        
        let nextIndex = (lastSamplePassageIndex + 1) % sampleAnalyses.count
        lastSampleAnalysisIndex = nextIndex
        return sampleAnalyses[nextIndex]
    }
    
    func createSampleItem(inModelContext modelContext: ModelContext) {
        if let codableItem = nextSampleAnalysis() {
            let sampleItem = codableItem.toModel()
            sampleItem.analysisState = .completed
            modelContext.insert(sampleItem)
        }   
    }
    
    private func loadSamplePassages() {
        if let url = Bundle.main.url(forResource: samplePassagesPlistName, withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let array = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String] {
            samplePassages = array
        } else {
            print("Failed to load samples from plist.")
        }
    }
    
    private func loadSampleAnalyses() {
        do {
            sampleAnalyses = try loadCodableItemsFromPlist()
        } catch {
            print("Failed to load samples from plist.")
        }
    }
}
