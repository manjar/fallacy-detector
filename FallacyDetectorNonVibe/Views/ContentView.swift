//
//  ContentView.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showInputSheet = false
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showInputSheet = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showInputSheet) {
                InputSheet { inputText in
                    withAnimation {
                        let newItem = Item(timestamp: Date(), inputText: inputText)
                        modelContext.insert(newItem)
                        Task {
                            let processor = FallacyProcessor(promptSender: GeminiPromptSender())
                            let fallacies = await processor.analyze(text: inputText)
                            await MainActor.run {
                                if let fallacies {
                                    newItem.saveFallacyResults(fallacies)
                                    newItem.errorMessage = nil
                                } else {
                                    newItem.fallacyResultsJSON = nil
                                    newItem.errorMessage = "No fallacies found or analysis failed."
                                }
                                // If needed, save context here
                            }
                        }
                    }
                    showInputSheet = false
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
