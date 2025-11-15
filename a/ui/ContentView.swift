//
//  ContentView.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(StatesManager.self) private var statesManager
    
    @FocusState private var isURLBarFocused: Bool
    
    
    var body: some View {
        
        ZStack {
            WebView(
                
            )
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                Spacer()
                if (statesManager.uiStates.isBottomPanelVisible) {
                    BottomPanelView(
                        isURLBarFocused : $isURLBarFocused,
                    )
                } else {
                    BackSquareView()
                }
                
                
            }
            .ignoresSafeArea(.container)
            
        }
        .statusBarHidden()
        .background(.black)
        .onAppear {
            if statesManager.persistentStates.currentUrl.isEmpty {
                statesManager.persistentStates.currentUrl = settingsManager.settings.defaultUrl
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SettingsManager())
    
    
}
