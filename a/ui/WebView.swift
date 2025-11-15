//
//  WebView.swift
//  a
//
//  Created by Tom on 11/13/25.
//

import SwiftUI
import WebKit


class InteractiveWKWebView: WKWebView {
    /// This closure will be called whenever the user touches the web view.
    var onUserInteraction: (() -> Void)?

    // We override hitTest, which is a fundamental UIKit method called
    // whenever a touch occurs within a view's bounds. This is the most
    // reliable way to detect any interaction before it's even processed
    // as a scroll, tap, etc.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // As soon as a touch is detected, we call our closure.
        onUserInteraction?()
        
        // It's crucial to call the superclass's implementation so that the
        // web view can continue to handle the touch normally (e.g., clicking links).
        return super.hitTest(point, with: event)
    }
}

struct WebView: UIViewRepresentable {
    
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(StatesManager.self) private var statesManager
    
    
    //  makeCoordinator ---
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self) // Now explicitly calls the init
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = InteractiveWKWebView()
        
        webView.onUserInteraction = {
            if (statesManager.uiStates.isBottomPanelVisible) {
                statesManager.uiStates.isBottomPanelVisible = false
            }
        }
        webView.navigationDelegate = context.coordinator
        // ... (rest of makeUIView)
        webView.layer.cornerRadius = settingsManager.settings.deviceCornerRadius
        webView.clipsToBounds = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // ... (rest of updateUIView)
        if let currentWebViewURL = uiView.url?.absoluteString, currentWebViewURL == statesManager.persistentStates.currentUrl {
            // Do nothing
        } else if let url = URL(string: statesManager.persistentStates.currentUrl) {
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
                parent._statesManager.wrappedValue.persistentStates.currentUrl = urlString
            }
        }
    }
}
#Preview {
    WebView()
}
