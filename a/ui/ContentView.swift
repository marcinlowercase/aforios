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
                BottomPanelView(
                    isURLBarFocused : $isURLBarFocused,
                )
            }
            .ignoresSafeArea(.container)
            
        }
        .statusBarHidden()
        .background(.black)
        .onAppear {
            if statesManager.states.currentUrl.isEmpty {
                statesManager.states.currentUrl = settingsManager.settings.defaultUrl
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SettingsManager())
    
    
}
