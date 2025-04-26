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
    @State private var showSummarySheet = false
    @Query private var items: [Item]
    @State private var selectedItem: Item? = nil

    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    ForEach(items) { item in
                        NavigationLink {
                            FallacyView(inputText: item.inputText, fallacies: item.fallacyResults)
                        } label: {
                            VStack {
                                ListCell(item: item)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                } header: {
                    Text("Saved analyses")
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showSummarySheet = true }) {
                        Label("View Summary", systemImage: "info.square")
                    }
                }
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
                            let fallacies = await processor.fetch(text: inputText)
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
            .sheet(isPresented: $showSummarySheet) {
                SummaryView(summary: SummaryGenerator(items: items).summary)
            }
        } detail: {
            if let item = selectedItem {
                FallacyView(inputText: item.inputText, fallacies: item.fallacyResults)
            } else {
                Text("Select an item")
            }
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
