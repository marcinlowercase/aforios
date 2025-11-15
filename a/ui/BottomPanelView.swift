//
//  URLBarView.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import SwiftUI
import UIKit

struct BottomPanelView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(StatesManager.self) private var statesManager


    
    
    var isURLBarFocused: FocusState<Bool>.Binding


    
    var body: some View {
        
        VStack {
            
            UrlBarView(
                isFocused: isURLBarFocused,
            )
            
        }
        .padding(settingsManager.settings.padding)
        
        // like LaunchedEffect in Compose
        .onChange(of: isURLBarFocused.wrappedValue) {
            
            if !isURLBarFocused.wrappedValue {
                
            }
        }
    }
    
    
}
