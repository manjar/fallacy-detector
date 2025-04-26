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
                    .frame(minHeight: 200, maxHeight: 300)
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
                        inputText = """
                            The most remarkable thing about what's going on in AI right now is that a lot of applications have gone from "not particularly useful" to "very useful a lot of the time". It's a huge set of advancements that are making it easier to prove the value of AI in many settings.

                            Because of autonomous driving's intrinsic characteristics, however, these advancements aren't fully applicable. The two main issues are 1) the long tail of unusual circumstances that must be trained, and 2) the stakes.

                            Look at tools such as Cursor which are well on their way to completely transforming how programming is done. That domain is very well teed up for AI, as the problem space is highly constrained relative to "the real world". So it's easy to get to "good enough", which might be "speeds up my work 80% of the time" or something like that. In the Tesla case, there are untold variations on real-world conditions, including weather, construction, etc.

                            Regarding stakes, it's a lot easier to recover from an error when an LLM is telling you how to write your "for" loop, or even your CV, than it is when your car wants to run a red light (plenty of videos of FSD doing that, posted here on reddit). It will never be "good enough" to "not run red lights 99.9999% of the time".

                            Having said all that, it's quite possible that any day/week/month a new discovery will be made that suddenly advances the capabilities of autonomous driving. But we must keep in mind that such an advancement could very well come from outside of Tesla (think DeepSeek). If that were the case, it wouldn't be a strategic advantage for Tesla, and might in fact be the opposite, especially if it relies on data from sensors that aren't currently built into Tesla vehicles.
                            """
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
