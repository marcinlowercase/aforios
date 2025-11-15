//
//  SettingsManager.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import Foundation
import Combine
import SwiftUI

struct BrowserSettings {
    let padding: CGFloat
    let deviceCornerRadius: CGFloat
    let defaultUrl: String
    let animationSpeed: CGFloat
    let minBaseCornerRadius: CGFloat
    // need more element
}



// single state to pass down the whole app

@Observable
class SettingsManager {
    
    var settings: BrowserSettings {
        didSet {
            save()
        }
    }
    
    private enum Keys {
        static let padding = "padding_dp"
        static let deviceCornerRadius = "corner_radius_dp"
        static let defaultUrl = "default_url"
        static let animationSpeed = "animation_speed"
        static let minBaseCornerRadius = "min_base_corner_radius"
    }
    
    init() {
        let defaults = UserDefaults.standard
        let padding = defaults.double(forKey: Keys.padding) == 0 ? 8.0 : defaults.double(forKey: Keys.padding)
        let cornerRadius = defaults.double(forKey: Keys.deviceCornerRadius) == 0 ? 54.85 : defaults.double(forKey: Keys.deviceCornerRadius)
        let url = defaults.string(forKey: Keys.defaultUrl) ?? "https://arc.net"
        let speed = defaults.double(forKey: Keys.animationSpeed) == 0 ? 300.0 : defaults.double(forKey: Keys.animationSpeed)
        let height = defaults.double(forKey: Keys.minBaseCornerRadius) == 0 ? 50.0 : defaults.double(forKey: Keys.minBaseCornerRadius)
        
        self.settings = BrowserSettings(
            padding: padding,
            deviceCornerRadius: cornerRadius,
            defaultUrl: url,
            animationSpeed: speed,
            minBaseCornerRadius: height
        )
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(settings.padding, forKey: Keys.padding)
        defaults.set(settings.deviceCornerRadius, forKey: Keys.deviceCornerRadius)
        defaults.set(settings.defaultUrl, forKey: Keys.defaultUrl)
        defaults.set(settings.animationSpeed, forKey: Keys.animationSpeed)
        defaults.set(settings.minBaseCornerRadius, forKey: Keys.minBaseCornerRadius)
        print("Browser settings saved.")
    }
}
