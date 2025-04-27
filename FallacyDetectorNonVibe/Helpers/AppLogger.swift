//
//  AppLogger.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/27/25.
//

import Foundation
import os

struct AppLogger {
    static let views = Logger(subsystem: "com.apps.fallacydetector", category: "Views")
    static let viewModel = Logger(subsystem: "com.apps.fallacydetector", category: "ViewModel")
    static let model = Logger(subsystem: "com.apps.fallacydetector", category: "Model")
    static let fetch = Logger(subsystem: "com.apps.fallacydetector", category: "Fetch")
    static let misc = Logger(subsystem: "com.apps.fallacydetector", category: "Misc")
}
