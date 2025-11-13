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
    
    
    var body: some View {
        let settings = settingsManager.settings
        
        ZStack {
            // The WebView can also use the default URL from settings in the future.
            WebView(urlString: currentURLString, cornerRadius: settings.deviceCornerRadius)
                .ignoresSafeArea(edges: .bottom)
            
            VStack {
                Spacer()
                URLBarView(onURLSubmit: { newURL in
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

struct WebView: UIViewRepresentable {
    let urlString: String
    let cornerRadius: CGFloat
    
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // 2. Apply the corner radius directly to the underlying UIKit view's layer
        webView.layer.cornerRadius = cornerRadius
        webView.clipsToBounds = true // This is the UIKit equivalent of .clipShape()
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
        
        // 3. Also update the corner radius if it changes while the app is running
        uiView.layer.cornerRadius = cornerRadius
    }
}


#Preview {
    ContentView()
        .environmentObject(SettingsManager())
    
    
}
