//
//  SettingsManager.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import Foundation
import Combine
import SwiftUI // Needed for ObservableObject and CGFloat

// This struct is a direct translation of your Kotlin data class.
// It holds all the settings in one place.
struct BrowserSettings {
    let paddingDp: CGFloat
    let deviceCornerRadius: CGFloat
    let defaultUrl: String
    let animationSpeed: CGFloat
    let singleLineHeight: CGFloat
    // Add other settings from your data class here as you need them
}

// Your class declaration should look like this.
// It must be a 'class' and must include ': ObservableObject'
class SettingsManager: ObservableObject {

    @Published var settings: BrowserSettings {
        didSet {
            save()
        }
    }

    private enum Keys {
        static let paddingDp = "padding_dp"
        static let deviceCornerRadius = "corner_radius_dp"
        static let defaultUrl = "default_url"
        static let animationSpeed = "animation_speed"
        static let singleLineHeight = "single_line_height"
    }

    init() {
        let defaults = UserDefaults.standard
        let padding = defaults.double(forKey: Keys.paddingDp) == 0 ? 8.0 : defaults.double(forKey: Keys.paddingDp)
        let cornerRadius = defaults.double(forKey: Keys.deviceCornerRadius) == 0 ? 54.85 : defaults.double(forKey: Keys.deviceCornerRadius)
        let url = defaults.string(forKey: Keys.defaultUrl) ?? "https://arc.net"
        let speed = defaults.double(forKey: Keys.animationSpeed) == 0 ? 300.0 : defaults.double(forKey: Keys.animationSpeed)
        let height = defaults.double(forKey: Keys.singleLineHeight) == 0 ? 50.0 : defaults.double(forKey: Keys.singleLineHeight)

        self.settings = BrowserSettings(
            paddingDp: padding,
            deviceCornerRadius: cornerRadius,
            defaultUrl: url,
            animationSpeed: speed,
            singleLineHeight: height
        )
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(settings.paddingDp, forKey: Keys.paddingDp)
        defaults.set(settings.deviceCornerRadius, forKey: Keys.deviceCornerRadius)
        defaults.set(settings.defaultUrl, forKey: Keys.defaultUrl)
        defaults.set(settings.animationSpeed, forKey: Keys.animationSpeed)
        defaults.set(settings.singleLineHeight, forKey: Keys.singleLineHeight)
        print("Browser settings saved.")
    }
}
