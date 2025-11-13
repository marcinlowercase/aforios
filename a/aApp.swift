//
//  aApp.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import SwiftUI

@main
struct aApp: App {
    
    // that will live for the entire lifetime of the app.
    @State private var settingsManager = SettingsManager()
    @State private var statesManager  = StatesManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settingsManager)
                .environment(statesManager)
        }
    }
}
