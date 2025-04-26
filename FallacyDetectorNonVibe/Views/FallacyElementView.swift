//
//  AnalysisElementView.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import SwiftUI

struct FallacySuggestionView: View {
    let suggestionType: SuggestionType
    let suggestion: String
    
    enum SuggestionType: String {
        case recap = "Fallacious passage"
        case counter = "How to counter"
        case avoidance = "What to do instead"
        
        var color: Color {
            switch self {
            case .recap:
                return .blue
            case .counter:
                return .red
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
        .padding()
        .background(suggestionType.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct FallacyElementView: View {
    let fallacy: Fallacy
    var body: some View {
        VStack(spacing: 15) {
            FallacySuggestionView(suggestionType: .recap, suggestion: fallacy.originalText)
            Text(fallacy.fallacy)
                .font(.headline)
            FallacySuggestionView(suggestionType: .avoidance, suggestion: fallacy.avoidance)
            FallacySuggestionView(suggestionType: .counter, suggestion: fallacy.counter)
            Link("Learn more on Wikipedia", destination: URL(string: fallacy.reference)!)
                .font(.caption)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    FallacyElementView(fallacy: Fallacy(fallacy: "Fallacy name", originalText: "Original text", avoidance: "How to avoid", counter: "How to counter", reference: "http://example.com"))
}
