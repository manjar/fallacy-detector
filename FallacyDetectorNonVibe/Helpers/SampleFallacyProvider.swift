//
//  SampleFallacyProvider.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/26/25.
//

import Foundation

final class SampleProvider {
    private let plistName = "SamplePassages"
    private let userDefaultsKey = "SampleProvider.LastIndex"
    private var samples: [String] = []
    private var lastIndex: Int {
        get { UserDefaults.standard.integer(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }
    
    init() {
        loadSamples()
    }
    
    func nextSample() -> String? {
        guard !samples.isEmpty else { return nil }
        let nextIndex = (lastIndex + 1) % samples.count
        lastIndex = nextIndex
        return samples[nextIndex]
    }
    
    func currentSample() -> String? {
        guard !samples.isEmpty else { return nil }
        return samples[lastIndex % samples.count]
    }
    
    private func loadSamples() {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let array = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String]
        else {
            print("Failed to load samples from plist.")
            return
        }
        samples = array
    }
}
