//
//  StatesManager.swift
//  a
//
//  Created by Tom on 11/13/25.
//

import Foundation
import Combine
import SwiftUI

struct BrowserStates {
    var currentUrl: String
    // need more element
}



// single state to pass down the whole app

@Observable
class StatesManager {
    
    var states: BrowserStates {
        didSet {
            save()
        }
    }
    
    private enum Keys {
        static let currentUrl = "current_url"
        
    }
    
    init() {
        let defaults = UserDefaults.standard
        
        let currentUrl = defaults.string(forKey: Keys.currentUrl) ?? ""
        
        self.states = BrowserStates(
            currentUrl: currentUrl
        )
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(states.currentUrl, forKey: Keys.currentUrl)
        print("Browser states saved.")
    }
}

