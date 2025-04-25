//
//  APIKey.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import Foundation

enum APIKey: String {
    case gemini = "Gemini_API_KEY"
    case openAI = "OpenAI_API_KEY"
    
    /// Retrieves the API key for the specified service from the property list.
    var value: String {
        guard let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {
            fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let key = plist?.object(forKey: self.rawValue) as? String else {
            fatalError("Couldn't find key '\(self.rawValue)' in 'GenerativeAI-Info.plist'.")
        }
        return key
    }
}
