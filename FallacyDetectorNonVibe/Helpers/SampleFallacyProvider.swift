//
//  SampleFallacyProvider.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/26/25.
//

import Foundation

final class SampleProvider {
    // MARK: - Properties
    
    private let plistName = "SamplePassages"
    private let userDefaultsKey = "SampleProvider.LastIndex"
    private var samples: [String] = []
    private var lastIndex: Int {
        get { UserDefaults.standard.integer(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }
    
    // MARK: - Initialization
    
    init() {
        loadSamples()
    }
    
    // MARK: - Public Methods
    
    /// Returns the next sample in the list, cycling back to the start as needed.
    func nextSample() -> String? {
        guard !samples.isEmpty else { return nil }
        let nextIndex = (lastIndex + 1) % samples.count
        lastIndex = nextIndex
        return samples[nextIndex]
    }
    
    /// Returns the current sample (the last one retrieved), or the first if none yet.
    func currentSample() -> String? {
        guard !samples.isEmpty else { return nil }
        return samples[lastIndex % samples.count]
    }
    
    // MARK: - Private Methods
    
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
