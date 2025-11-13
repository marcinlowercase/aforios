//
//  ContentView.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentURLString: String = ""
    @FocusState private var isURLBarFocused: Bool

    
    
    var body: some View {
        let settings = settingsManager.settings
        
        ZStack {
            // The WebView can also use the default URL from settings in the future.
            WebView(urlString: currentURLString,
                    cornerRadius: settings.deviceCornerRadius,
                    onURLChanged: { newURL in
                // When the WebView tells us its URL has changed,
                // we update our single source of truth.
                self.currentURLString = newURL
            }
            )
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                Spacer()
                URLBarView(
                    urlText: $currentURLString,
                    isFocused: $isURLBarFocused,
                    onURLSubmit: { newURL in
                        // When the URL bar submits, we update our state.
                        // SwiftUI will automatically reload the WebView with the new URL.
                        self.currentURLString = newURL
                    })
            }
            .ignoresSafeArea(.container)
            
        }
        .statusBarHidden()
        .onAppear {
            if currentURLString.isEmpty {
                self.currentURLString = settingsManager.settings.defaultUrl
            }
        }
    }
}

// MARK: - WebView (UIViewRepresentable)
struct WebView: UIViewRepresentable {
    let urlString: String
    let cornerRadius: CGFloat
    var onURLChanged: (String) -> Void

    // --- UPDATED makeCoordinator ---
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self) // Now explicitly calls the init
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        // ... (rest of makeUIView)
        webView.layer.cornerRadius = cornerRadius
        webView.clipsToBounds = true
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // ... (rest of updateUIView)
        if let currentWebViewURL = uiView.url?.absoluteString, currentWebViewURL == urlString {
            // Do nothing
        } else if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
        uiView.layer.cornerRadius = cornerRadius
    }
    
    // --- UPDATED Coordinator ---
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        // Explicitly define the initializer with a label
        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let urlString = webView.url?.absoluteString {
                parent.onURLChanged(urlString)
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(SettingsManager())
    
    
}
