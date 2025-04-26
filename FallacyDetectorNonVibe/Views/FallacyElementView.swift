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
    let fallacy: Fallacy
    var body: some View {
        VStack(spacing: 15) {
            FallacyElementSubview(suggestionType: .recap, suggestion: fallacy.originalText)
            FallacyElementSubview(suggestionType: .fallacy, suggestion: fallacy.fallacy)
            FallacyElementSubview(suggestionType: .avoidance, suggestion: fallacy.avoidance)
            FallacyElementSubview(suggestionType: .counter, suggestion: fallacy.counter)
            Link("Learn more on Wikipedia", destination: URL(string: fallacy.reference)!)
                .font(.caption)
                .padding()
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    FallacyElementView(fallacy: Fallacy(fallacy: "Fallacy name", originalText: "Original text", avoidance: "How to avoid", counter: "How to counter", reference: "http://example.com"))
}
