//
//  AnalysisElementView.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import SwiftUI

struct FallacyElementSubview: View {
    let suggestionType: SuggestionType
    let suggestion: String
    
    enum SuggestionType: String {
        case recap = "Fallacious passage"
        case fallacy = "Fallacy"
        case counter = "How to counter"
        case avoidance = "What to do instead"
        
        var color: Color {
            switch self {
            case .recap:
                return .blue
            case .fallacy:
                return .red
            case .counter:
                return .yellow
            case .avoidance:
                return .green
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(suggestionType.rawValue)
                .font(.headline)
            Text(suggestion)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(suggestionType.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct FallacyElementView: View {
    let fallacyInstance: FallacyInstance
    var body: some View {
        VStack(spacing: 15) {
            FallacyElementSubview(suggestionType: .recap, suggestion: fallacyInstance.originalText)
            FallacyElementSubview(suggestionType: .fallacy, suggestion: fallacyInstance.fallacy)
            FallacyElementSubview(suggestionType: .avoidance, suggestion: fallacyInstance.avoidance)
            FallacyElementSubview(suggestionType: .counter, suggestion: fallacyInstance.counter)
            Link("Learn more on Wikipedia", destination: fallacyInstance.link)
                .font(.caption)
                .padding()
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    FallacyElementView(fallacyInstance: FallacyInstance(originalText: "Original text", fallacy: "Fallacy name", avoidance: "What to do instead", counter: "How to counter it", link: URL(string: "http://example.com")!))
}
