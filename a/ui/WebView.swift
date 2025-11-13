//
//  WebView.swift
//  a
//
//  Created by Tom on 11/13/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(StatesManager.self) private var statesManager
    
    
    // --- UPDATED makeCoordinator ---
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self) // Now explicitly calls the init
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        // ... (rest of makeUIView)
        webView.layer.cornerRadius = settingsManager.settings.deviceCornerRadius
        webView.clipsToBounds = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // ... (rest of updateUIView)
        if let currentWebViewURL = uiView.url?.absoluteString, currentWebViewURL == statesManager.states.currentUrl {
            // Do nothing
        } else if let url = URL(string: statesManager.states.currentUrl) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
        uiView.layer.cornerRadius = settingsManager.settings.deviceCornerRadius
    }
    
    // --- UPDATED Coordinator ---
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        // Explicitly define the initializer with a label
        init(parent: WebView) {
            self.parent = parent
        }
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading")
            if let urlString = webView.url?.absoluteString {
                // Call the callback to update the state in the parent view (ContentView).
                parent._statesManager.wrappedValue.states.currentUrl = urlString
            }
        }
    }
}
#Preview {
    WebView()
}
