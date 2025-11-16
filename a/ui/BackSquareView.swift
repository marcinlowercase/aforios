//
//  BottomSquareView.swift
//  a
//
//  Created by Tom on 11/14/25.
//

import SwiftUI

struct BackSquareView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(StatesManager.self) private var statesManager
    var body: some View {
        HStack (spacing: 0) {
            if !statesManager.persistentStates.isBackSquareLeft { Spacer() }
            ZStack {
                Image("back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
            }
            
            .frame(
                height: settingsManager.settings.heightForLayer(layer: 1)
            )
            .containerRelativeFrame(.horizontal) { length, axis in
                return length * 0.4
            }
            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: settingsManager.settings.cornerRadiusForLayer(layer: 1)))
            .padding(settingsManager.settings.padding)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // 'value.translation' tells us how far the finger moved.
                        // A swipe up results in a NEGATIVE height (vertical) translation.
                        let verticalDistance = value.translation.height
                        let horizontalDistance = value.translation.width
                        
                        // To make the gesture feel intentional, we'll set a threshold.
                        // The user must swipe up at least 50 points.
                        let verticalSwipeThreshold: CGFloat = -50
                        let horizontalSwipeThreshold: CGFloat = 50
                        
                        // We also check if the swipe was more vertical than horizontal.
                        if verticalDistance < verticalSwipeThreshold && abs(verticalDistance) > abs(horizontalDistance) {
                            print("Back Square Swipe Up")
                            // If the conditions are met, it's a clear swipe up.
                            // Now, we change the state.
                            statesManager.uiStates.isBottomPanelVisible = true
                        } else if abs(horizontalDistance) > horizontalSwipeThreshold {
                            if horizontalDistance > 0 {
                                print("Back Square Swipe Right")
                                statesManager.persistentStates.isBackSquareLeft = false
                            } else {
                                print("Back Square Swipe Left")

                                statesManager.persistentStates.isBackSquareLeft = true
                            }
                        }
                    }
            )
            
            if statesManager.persistentStates.isBackSquareLeft { Spacer() }

        }
        
        
    }
}

#Preview {
    BackSquareView()
}
