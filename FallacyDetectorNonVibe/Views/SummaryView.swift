//
//  SummaryView.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import SwiftUI

struct SummaryView: View {
    let summary: Summary
    
    var body: some View {
        VStack {
            Group {
                VStack {
                    Text("Analyses:")
                    Text("\(summary.countOfAnalyses)")
                }
                VStack {
                    Text("Fallacies found:")
                    Text("\(summary.countOfFallacies)")
                }
            }
            .frame(maxWidth: .infinity)
            .font(.largeTitle)
            .padding()
            .background(Color.purple.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview {
//    SummaryView()
}
