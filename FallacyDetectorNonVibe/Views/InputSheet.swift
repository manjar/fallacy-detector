//
//  InputSheet.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//
import SwiftUI
import UniformTypeIdentifiers

struct InputSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""
    var onAnalyze: (String) -> Void
    @State private var droppedImage: UIImage? = nil
    @State private var isTargeted = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Paste or type text to analyze, or drop image here:")
                    .font(.headline)

                // Large multi-line input
                TextEditor(text: $inputText)
                    .padding(8)
                    .frame(minHeight: 200, maxHeight: .infinity)
                    .overlay(
                            Group {
                                if isTargeted {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.5), lineWidth: 4)
                                        .background(Color.blue.opacity(0.2).cornerRadius(8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3))
                                }
                            }
                        )
                    .font(.body)
                
                HStack {
                    Button(action: {
                        if let clipboard = UIPasteboard.general.string {
                            inputText = clipboard
                        }
                    }) {
                        Label("Paste", systemImage: "doc.on.clipboard")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        inputText = SampleProvider().nextSamplePassage()!
                    }) {
                        Label("Sample", systemImage: "text.quote")
                    }
                    
                    Spacer()
                    
                    Button("Analyze") {
                        onAnalyze(inputText)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onDrop(of: [UTType.image.identifier, UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
                for provider in providers {
                    print("Provider registered types: \(provider.registeredTypeIdentifiers)")
                }
                if let provider = providers.first {
                    
                    if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        provider.loadObject(ofClass: UIImage.self) { object, error in
                            if let image = object as? UIImage {
                                Task {
                                    await handleImageDrop(image)
                                }
                            }
                        }
                        return true
                        
                    } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (urlData, error) in
                            if let data = urlData as? Data,
                               let url = URL(dataRepresentation: data, relativeTo: nil),
                               let image = UIImage(contentsOfFile: url.path) {
                                Task {
                                    await handleImageDrop(image)
                                }
                            }
                        }
                        return true
                    }
                }
                return false
            }
        }
    }
    
    @MainActor
    func handleImageDrop(_ image: UIImage) async {
        do {
            let recognizedStrings = try await recognizeTextInImage(image)
            self.inputText = recognizedStrings.joined(separator: " ")
        } catch {
            // TODO: handle the error (you could add an @State errorMessage and show an Alert, for example)
        }
    }
}
