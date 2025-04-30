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
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            VStack {
                if items.isEmpty {
                    emptyView
                } else {
                    List {
                        Section {
                            ForEach(filteredItems) { item in
                                navLink(item: item)
                            }
                            .onDelete(perform: deleteItems)
                        } header: {
                            searchText.isEmpty ? Text("Saved analyses") : (filteredItems.isEmpty ? Text("No matches") : Text("Search results"))
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText)
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if DEBUG
                if !items.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            do {
                                let codableItems = items.map { $0.toCodable() }
                                try saveCodableItemsToPlist(codableItems)
                            } catch {
                                print("Failed to save plist: \(error)")
                                // Optionally: show alert to user
                            }
                        }) {
                            Label("Dump to plist", systemImage: "arrow.down.circle")
                        }
                    }
                }
#endif
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
                            let processor = FallacyProcessor(modelContext: modelContext)
                            await processor.createItemWithInputText(inputText)
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
                FallacyView(item: item)
            } else {
                Text("Select an item")
            }
        }
    }
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { item in
                item.inputText.localizedCaseInsensitiveContains(searchText) ||
                item.fallacyInstances.contains { fallacy in
                    [fallacy.avoidance, fallacy.counter, fallacy.fallacy]
                        .contains { $0.localizedCaseInsensitiveContains(searchText) }
                }
            }
        }
    }
        
    private func navLink(item: Item) -> some View {
        NavigationLink(destination: FallacyView(item: item)) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                    if item.analysisState == .inProgress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("\(item.fallacyInstances.count)")
                            .foregroundColor(.white)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    ListCell(item: item) // Your custom view
                }
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
                try? modelContext.save()
            }
        }
    }

    var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            
            Text("No Analyses Yet")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This app helps you find logical fallacies — errors in reasoning — in your text. Tap the **+** button to create a new analysis and discover what hidden fallacies might be hiding in your writing!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Create example") {
                print("would be creating an example")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
