//
//  SwiftUIView.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import SwiftUI

struct FallacyView: View {
    let inputText: String
    let fallacies: [Fallacy]?
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Spacer()
                Text("Original passage:")
                    .font(.headline)
                ScrollView {
                    Text(inputText)
                }
            }
            .frame(height: 200)
            .padding()
            .border(.black)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            Spacer()
            if let fallacies {
                List {
                    ForEach(fallacies) { fallacy in
                        FallacyElementView(fallacy: fallacy)
                    }
                }
            }
        }
        .background(Color.clear)
    }
}

#Preview {
    FallacyView(inputText: "Original text", fallacies: [Fallacy(fallacy: "Fallacy name", originalText: "Original text", avoidance: "How to avoid", counter: "How to counter", reference: "URL string"),
                            Fallacy(fallacy: "Fallacy name", originalText: "Original text", avoidance: "How to avoid", counter: "How to counter", reference: "URL string")])
}
