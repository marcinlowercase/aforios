//
//  BrowserSettings+Extensions.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import Foundation


// We are extending the BrowserSettings struct, adding new methods to it.
extension BrowserSettings {

    /// Calculates the corner radius for a UI layer based on the settings.
    func cornerRadiusForLayer(layer: Int) -> CGFloat {
        // Base case: Layer 0 is the screen's edge.
        if layer == 0 {
            // It can now directly access 'self.deviceCornerRadius' or just 'deviceCornerRadius'.
            return self.deviceCornerRadius
        }
        
        // Recursive step: It calls itself and uses 'self.paddingDp'.
        // The values are no longer passed in as parameters; they are part of the struct.
        let previousLayerRadius = self.cornerRadiusForLayer(layer: layer - 1)
        return max(0, previousLayerRadius - self.paddingDp)
    }

    /// Calculates the height for a UI layer based on the settings.
    func heightForLayer(layer: Int) -> CGFloat {
        if self.deviceCornerRadius > self.singleLineHeight {
            return self.cornerRadiusForLayer(layer: layer) * 2
        } else {
            // For the fallback case, we still need to calculate with a fixed 50.0 radius,
            // but we use the padding from the settings object.
            let tempSettings = BrowserSettings(
                paddingDp: self.paddingDp,
                deviceCornerRadius: 50.0, // Temporary hardcoded radius for this specific case
                defaultUrl: self.defaultUrl,
                animationSpeed: self.animationSpeed,
                singleLineHeight: self.singleLineHeight
            )
            return tempSettings.cornerRadiusForLayer(layer: layer) * 2
        }
    }
}
