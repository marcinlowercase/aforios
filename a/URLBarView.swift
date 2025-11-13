//
//  URLBarView.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import SwiftUI

struct URLBarView: View {
    // @EnvironmentObject finds and connects to the SettingsManager
    // that we provided in the App file.
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var urlText: String = "https://arc.net"
    
    @FocusState private var isTextFieldFocused: Bool
    
    var onURLSubmit: (String) -> Void
    
    var body: some View {
        // We now access the settings via 'settingsManager.settings'
        let settings = settingsManager.settings
        
        ZStack {
            TextField("URL", text: $urlText)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .focused($isTextFieldFocused)
                .onSubmit {
                    handleSubmit()
                }
                .submitLabel(.go)
        }
        .frame(height: settings.heightForLayer(layer: 1))
        .glassEffect(.regular, in: .rect(cornerRadius: settings.cornerRadiusForLayer(layer: 1)))
        .padding(settings.paddingDp)
        .onTapGesture {
            isTextFieldFocused = true
        }
        
        
        
    }
    
    private func handleSubmit() {
        // Dismiss the keyboard
        isTextFieldFocused = false
        
        let inputText = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        if inputText.isEmpty { return }
        
        var finalURLString: String
        
        // Check if the input looks like a URL.
        if inputText.contains(".") && !inputText.contains(" ") {
            // It's a URL. Make sure it has a scheme.
            if inputText.hasPrefix("https://") || inputText.hasPrefix("http://") {
                finalURLString = inputText
            } else {
                finalURLString = "https://" + inputText
            }
        } else {
            // It's a search term. Construct a Google search URL.
            // We must percent-encode the query to handle spaces and special characters.
            if let encodedQuery = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                finalURLString = "https://www.google.com/search?q=" + encodedQuery
            } else {
                // If encoding fails, do nothing.
                return
            }
        }
        
        // Use our callback to send the final URL string up to the parent view.
        onURLSubmit(finalURLString)
    }
}



#Preview {
    // For the preview to work, we must provide a sample SettingsManager.
    URLBarView(onURLSubmit:  {newUrl in
    })
    .environmentObject(SettingsManager())
    .background(Color.blue)
}
