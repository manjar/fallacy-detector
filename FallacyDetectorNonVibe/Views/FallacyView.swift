//
//  SwiftUIView.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import SwiftUI

struct FallacyView: View {
    let item: Item
    @State private var showHelpSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Spacer()
                Text("Original passage:")
                    .font(.headline)
                ScrollView {
                    Text(item.inputText)
                }
            }
            .frame(height: 200)
            .padding()
            .border(.black)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            Spacer()
            List {
                Section {
                    ForEach(Array(item.fallacyInstances.enumerated()), id: \.offset) { index, fallacyInstance in
                        HStack {
                            Spacer()
                            Text("Fallacy \(index + 1)")
                                .font(.title)
                            Spacer()
                        }
                        FallacyElementView(fallacyInstance: fallacyInstance)
                            .listRowSeparator(.hidden)
                    }
                } header: {
                    HStack {
                        Text("Findings")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showHelpSheet = true
                        }) {
                            Image(systemName: "questionmark.circle")
                        }
                        .buttonStyle(BorderlessButtonStyle()) // important for tappability in headers
                    }
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
        }
        .background(Color.clear)
        .sheet(isPresented: $showHelpSheet) {
            helpView
        }
        .navigationTitle("Detail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        let processor = FallacyProcessor(promptSender: GeminiPromptSender())
                        let fallacies = await processor.fetch(text: item.inputText)
                        await MainActor.run {
                            if let fallacies {
                                item.saveFallacyResults(fallacies)
                                item.errorMessage = nil
                            } else {
                                item.fallacyResponseJSON = nil
                                item.errorMessage = "No fallacies found or analysis failed."
                            }
                        }
                    }
                }) {
                    Label("Re-Analyze", systemImage: "arrow.clockwise")
                }
            }
        }
    }
    
    var helpView: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome to Fallacy Detector!")
                        .font(.title)
                        .bold()
                    
                    Text("This app helps you spot logical fallacies — errors in reasoning — in any text you input. When a fallacy is found, you'll see several sections:")
                    
                    Group {
                        Text("• **Fallacious Passage**")
                            .font(.headline)
                        Text("The specific part of your text where the fallacy was detected.")
                        
                        Text("• **Fallacy**")
                            .font(.headline)
                        Text("The name of the fallacy, followed by a short definition explaining the mistake in reasoning.")
                        
                        Text("• **What to Do Instead**")
                            .font(.headline)
                        Text("Advice on how you can avoid making this mistake yourself and strengthen your arguments.")
                        
                        Text("• **How to Counter**")
                            .font(.headline)
                        Text("Tips on how to respond if someone uses this fallacy during a discussion or argument.")
                    }
                }
                .padding()
            }
            .navigationTitle("Help")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showHelpSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    FallacyView(item: Item(timestamp: Date(), inputText: "This is the inpupt text"))
}
