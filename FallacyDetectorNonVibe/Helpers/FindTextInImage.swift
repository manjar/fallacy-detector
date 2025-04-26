//
//  FindTextInImage.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/26/25.
//
@preconcurrency import Vision
import UIKit

func recognizeTextInImage(_ image: UIImage) async throws -> [String] {
    guard let cgImage = image.cgImage else {
        return []
    }
    
    return try await withCheckedThrowingContinuation { continuation in
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            let recognizedStrings = request.results?
                .compactMap { $0 as? VNRecognizedTextObservation }
                .compactMap { $0.topCandidates(1).first?.string } ?? []
            
            continuation.resume(returning: recognizedStrings)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
