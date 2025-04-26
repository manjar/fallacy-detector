//
//  Untitled.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import Foundation

struct Summary {
    let countOfAnalyses: Int
    let countOfFallacies: Int
}

struct SummaryGenerator {
    let items: [Item]
    
    var summary: Summary {
        let countOfFallacies = items.map { $0.fallacyInstances.count }.reduce(0) { partialResult, fallacyCount in
            partialResult + fallacyCount
        }
        return Summary(countOfAnalyses: items.count, countOfFallacies: countOfFallacies)
    }
}
