//
//  StatesManager.swift
//  a
//
//  Created by Tom on 11/13/25.
//

import Foundation
import Combine
import SwiftUI

// Holds all state that should be SAVED and restored across app launches.
struct PersistentStates {
    var currentUrl: String
    var isBackSquareLeft: Bool = false 
    // need more element
}

struct UIStates {
    var isBottomPanelVisible: Bool = true
}


// single state to pass down the whole app

@Observable
class StatesManager {
    
    var persistentStates: PersistentStates {
        didSet {
            save()
        }
    }
    
    var uiStates: UIStates
    
    private enum Keys {
        static let currentUrl = "current_url"
        
    }
    
    init() {
        let defaults = UserDefaults.standard
        
        let currentUrl = defaults.string(forKey: Keys.currentUrl) ?? ""
        
        self.persistentStates = PersistentStates(
            currentUrl: currentUrl
        )
        self.uiStates = UIStates()
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(persistentStates.currentUrl, forKey: Keys.currentUrl)
        print("Browser persistent states saved.")
    }
}

