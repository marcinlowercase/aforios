//
//  aApp.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import SwiftUI

@main
struct aApp: App {
    
    // @StateObject creates a single, persistent instance of our manager
    // that will live for the entire lifetime of the app.
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)
        }
    }
}
