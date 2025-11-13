//
//  BrowserSettings+Extensions.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import Foundation


// extensions function to  the  BrowserSettings class
// -> have access to BrowserSettings directly
extension BrowserSettings {

    /// Calculates the corner radius for a UI layer based on device screen corner radius.
    func cornerRadiusForLayer(layer: Int) -> CGFloat {
        // Base case: Layer 0 is the screen's edge.
        if layer == 0 {
        
            return self.deviceCornerRadius
        }
        
        let previousLayerRadius = self.cornerRadiusForLayer(layer: layer - 1)
        return max(0, previousLayerRadius - self.paddingDp)
    }

    /// Calculates the height for a UI layer based on the current corner radius.
    func heightForLayer(layer: Int) -> CGFloat {
        if self.deviceCornerRadius > self.minBaseCornerRadius {
            return self.cornerRadiusForLayer(layer: layer) * 2
        } else {
           
            let tempSettings = BrowserSettings(
                paddingDp: self.paddingDp,
                deviceCornerRadius: self.minBaseCornerRadius, // Temporary hardcoded radius for this specific case
                defaultUrl: self.defaultUrl,
                animationSpeed: self.animationSpeed,
                minBaseCornerRadius: self.minBaseCornerRadius
            )
            return tempSettings.cornerRadiusForLayer(layer: layer) * 2
        }
    }
}
