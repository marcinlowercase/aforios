//
//  ContentView.swift
//  a
//
//  Created by Tom on 11/12/25.
//

// MARK: import
import Foundation
import SwiftUI
import WebKit
import Combine



// MARK: Data

class InteractiveWKWebView: WKWebView {
    /// This closure will be called whenever the user touches the web view.
    var onUserInteraction: (() -> Void)?
    
    var bottomObscuredHeight: CGFloat = 0

    // We override hitTest, which is a fundamental UIKit method called
    // whenever a touch occurs within a view's bounds. This is the most
    // reliable way to detect any interaction before it's even processed
    // as a scroll, tap, etc.A
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        print("hitTest")
//        print("point \(point)")
        
        
        let hitView = super.hitTest(point, with: event)
        
        let safeZoneLimit = self.bounds.height - bottomObscuredHeight

        if point.y < safeZoneLimit {
                   onUserInteraction?()
               }//        if hitView != nil {
//            // We defer the state update slightly to avoid conflicts during the hitTest runloop
//            DispatchQueue.main.async {
//                self.onUserInteraction?()
//            }
//        }
        
        return hitView
    }
}

// Holds all state that should be SAVED and restored across app launches.
struct PersistentStates {
    var currentUrl: String
    var isBackSquareLeft: Bool = false
    // need more element
}

struct UIStates {
    var isBottomPanelVisible: Bool = true
    var isTapBottomPanel: Bool = false
    var bottomPanelHeight: CGFloat = 0
}


// single state to pass down the whole app

@Observable
class StatesManager {
    
    var persistentStates: PersistentStates {
        didSet {
            save()
        }
    }
    
    var uiStates: UIStates
    
    private enum Keys {
        static let currentUrl = "current_url"
        
    }
    
    init() {
        let defaults = UserDefaults.standard
        
        let currentUrl = defaults.string(forKey: Keys.currentUrl) ?? ""
        
        self.persistentStates = PersistentStates(
            currentUrl: currentUrl
        )
        self.uiStates = UIStates()
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(persistentStates.currentUrl, forKey: Keys.currentUrl)
        print("Browser persistent states saved.")
    }
}

struct BrowserSettings {
    let padding: CGFloat
    let deviceCornerRadius: CGFloat
    let defaultUrl: String
    let animationSpeed: CGFloat
    let minBaseCornerRadius: CGFloat
    // need more element
    
    
    
    /// Calculates the corner radius for a UI layer based on device screen corner radius.
    func cornerRadiusForLayer(layer: Int) -> CGFloat {
        // Base case: Layer 0 is the screen's edge.
        if layer == 0 {
        
            return self.deviceCornerRadius
        }
        
        let previousLayerRadius = self.cornerRadiusForLayer(layer: layer - 1)
        return max(0, previousLayerRadius - self.padding)
    }

    /// Calculates the height for a UI layer based on the current corner radius.
    func heightForLayer(layer: Int) -> CGFloat {
        if self.deviceCornerRadius > self.minBaseCornerRadius {
            return self.cornerRadiusForLayer(layer: layer) * 2
        } else {
           
            let tempSettings = BrowserSettings(
                padding: self.padding,
                deviceCornerRadius: self.minBaseCornerRadius, // Temporary hardcoded radius for this specific case
                defaultUrl: self.defaultUrl,
                animationSpeed: self.animationSpeed,
                minBaseCornerRadius: self.minBaseCornerRadius
            )
            return tempSettings.cornerRadiusForLayer(layer: layer) * 2
        }
    }
}



// single state to pass down the whole app

@Observable
class SettingsManager {
    
    var settings: BrowserSettings {
        didSet {
            save()
        }
    }
    
    private enum Keys {
        static let padding = "padding_dp"
        static let deviceCornerRadius = "corner_radius_dp"
        static let defaultUrl = "default_url"
        static let animationSpeed = "animation_speed"
        static let minBaseCornerRadius = "min_base_corner_radius"
    }
    
    init() {
        let defaults = UserDefaults.standard
        let padding = defaults.double(forKey: Keys.padding) == 0 ? 8.0 : defaults.double(forKey: Keys.padding)
        let cornerRadius = defaults.double(forKey: Keys.deviceCornerRadius) == 0 ? 54.85 : defaults.double(forKey: Keys.deviceCornerRadius)
        let url = defaults.string(forKey: Keys.defaultUrl) ?? "https://arc.net"
        let speed = defaults.double(forKey: Keys.animationSpeed) == 0 ? 300.0 : defaults.double(forKey: Keys.animationSpeed)
        let height = defaults.double(forKey: Keys.minBaseCornerRadius) == 0 ? 50.0 : defaults.double(forKey: Keys.minBaseCornerRadius)
        
        self.settings = BrowserSettings(
            padding: padding,
            deviceCornerRadius: cornerRadius,
            defaultUrl: url,
            animationSpeed: speed,
            minBaseCornerRadius: height
        )
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(settings.padding, forKey: Keys.padding)
        defaults.set(settings.deviceCornerRadius, forKey: Keys.deviceCornerRadius)
        defaults.set(settings.defaultUrl, forKey: Keys.defaultUrl)
        defaults.set(settings.animationSpeed, forKey: Keys.animationSpeed)
        defaults.set(settings.minBaseCornerRadius, forKey: Keys.minBaseCornerRadius)
        print("Browser settings saved.")
    }
}





// MARK: Function

func domain(from urlString: String) -> String? {
    guard let url = URL(string: urlString), let host = url.host else {
        return nil
    }
    // Remove "www." prefix if it exists
    return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
}

// MARK: Preference Key

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: View

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
            print("onUserInteraction")
         
            if (statesManager.uiStates.isBottomPanelVisible) {
                statesManager.uiStates.isBottomPanelVisible = false
            }
            else {
                print("NOTFI")
            }
        }
        webView.navigationDelegate = context.coordinator
        // ... (rest of makeUIView)
        webView.layer.cornerRadius = settingsManager.settings.deviceCornerRadius
        webView.clipsToBounds = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        guard let interactiveWebView = uiView as? InteractiveWKWebView else { return }
        
        if statesManager.uiStates.isBottomPanelVisible {
            interactiveWebView.bottomObscuredHeight = statesManager.uiStates.bottomPanelHeight
        } else {
            interactiveWebView.bottomObscuredHeight = 0
        }
        
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
        .frame(maxWidth: .infinity)
        .padding(settingsManager.settings.padding)
        .contentShape(Rectangle())
        .allowsHitTesting(true)
        .background(.clear)
        .readHeight { height in
                    // 4. IMPORTANT: Wrap in main.async to ensure update happens
                    // after the view hierarchy is locked.
                    DispatchQueue.main.async {
                        if statesManager.uiStates.bottomPanelHeight != height {
                            print("Bottom Panel Height Updated: \(height)")
                            statesManager.uiStates.bottomPanelHeight = height
                        }
                    }
                }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // 'value.translation' tells us how far the finger moved.
                    // A swipe up results in a NEGATIVE height (vertical) translation.
                    let verticalDistance = value.translation.height
                    let horizontalDistance = value.translation.width
                    
                    // To make the gesture feel intentional, we'll set a threshold.
                    // The user must swipe up at least 50 points.
                    let verticalSwipeThreshold: CGFloat = 50
                    let horizontalSwipeThreshold: CGFloat = 50
                    
                    // We also check if the swipe was more vertical than horizontal.
                    if abs(verticalDistance) > verticalSwipeThreshold && abs(verticalDistance) > abs(horizontalDistance) {
                        
                        statesManager.uiStates.isTapBottomPanel = true
                        if verticalDistance < 0 {
                            print("Bottom Panel Swipe Up")
                            
                        } else {
                            print("Bottom Panel Swipe Up")

                        }
                      
                    } else if abs(horizontalDistance) > horizontalSwipeThreshold {
                        if horizontalDistance > 0 {
                            print("Bottom Panel Swipe Right")
                        } else {
                            print("Bottom Panel Swipe Left")
                        }
                    }
                }
        )
        
        
    }
    
    
}


struct BackSquareView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(StatesManager.self) private var statesManager
    var body: some View {
        HStack (spacing: 0) {
            if !statesManager.persistentStates.isBackSquareLeft { Spacer() }
            ZStack {
                Image("TomTransparent")
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
                        let verticalSwipeThreshold: CGFloat = 50
                        let horizontalSwipeThreshold: CGFloat = 50
                        
                        // We also check if the swipe was more vertical than horizontal.
                        if abs(verticalDistance) > verticalSwipeThreshold && abs(verticalDistance) > abs(horizontalDistance) {
                            
                            if verticalDistance < 0 {
                                print("Back Square Swipe Up")
                                statesManager.uiStates.isBottomPanelVisible = true
                            } else {
                                
                            }
                          
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


struct UrlBarView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(StatesManager.self) private var statesManager
    
    
    var isFocused: FocusState<Bool>.Binding
    @State private var urlText: String = ""
    
    var body: some View {
        
        ZStack {
            // UrlBar not focus -> invisible but still there to receive the tap event
            TextField("Search or type URL", text: $urlText)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .focused(isFocused)
                .onSubmit { handleSubmit() }
                .submitLabel(.go)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .allowsHitTesting(isFocused.wrappedValue)
                .opacity(isFocused.wrappedValue ? 1 : 0) // show only when focused
                .onTapGesture {
                    isFocused.wrappedValue = true
                    
                }
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { notification in
                    if let textField = notification.object as? UITextField {
                        // select all content when focus
                        textField.selectAll(nil)
                    }
                }
            
            // url bar unfocus -> show shorten url || search query if click search
            if let domain = domain(from: urlText) {
                Text(domain)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        isFocused.wrappedValue = true
                        print("Tap on domain")
                    }
                    .opacity(isFocused.wrappedValue ? 0 : 1)
                
            }
        }
       
        .frame(height: settingsManager.settings.heightForLayer(layer: 1))
        .background(.clear)
        .contentShape(Rectangle())
        .glassEffect(isFocused.wrappedValue ? .regular.interactive(): .clear.interactive(), in: .rect(cornerRadius: settingsManager.settings.cornerRadiusForLayer(layer: 1)))
        
//        .highPriorityGesture(
//            DragGesture(minimumDistance: 0) // minimumDistance: 0 lets it detect taps
//                .onEnded { value in
//                    print("Url Bar DragGesture.onEnded")
//                    // This code runs when the user lifts their finger.
//                    handleGesture(value)
//                }
//        )
        .onAppear{
            $urlText.wrappedValue = statesManager.persistentStates.currentUrl
        }
        .onChange(of: statesManager.persistentStates.currentUrl) { oldValue, newValue in
            urlText = newValue
        }
        .onChange(of: isFocused.wrappedValue){
            if ($urlText.wrappedValue != statesManager.persistentStates.currentUrl) {
                $urlText.wrappedValue = statesManager.persistentStates.currentUrl
            }
        }
    }
    
    private func handleGesture(_ value: DragGesture.Value) {
        
            print("handleGesture")
            let horizontalAmount = value.translation.width
            let verticalAmount = value.translation.height
            
            // --- Tap Detection ---
            // If the finger moved less than a tiny amount, we treat it as a tap.
            if abs(horizontalAmount) < 10 && abs(verticalAmount) < 10 {
                print("Gesture: TAP")
                isFocused.wrappedValue = true
                return // We're done
            }
            
            // --- Swipe Detection ---
            // Check if the swipe was primarily vertical or horizontal.
            if abs(verticalAmount) > abs(horizontalAmount) {
                // It's a vertical swipe.
                if verticalAmount < 0 {
                    print("Gesture: SWIPE UP")
                    // Here you could trigger other actions, e.g., show bookmarks.
                } else {
                    print("Gesture: SWIPE DOWN")
                    isFocused.wrappedValue = false // Swiping down could dismiss the keyboard.
                }
            } else {
                // It's a horizontal swipe.
                if horizontalAmount < 0 {
                    print("Gesture: SWIPE LEFT")
                    // Here you could trigger actions like "go to next tab".
                } else {
                    print("Gesture: SWIPE RIGHT")
                    // Here you could trigger actions like "go to previous tab".
                }
            }
        }
    
    private func handleSubmit() {
        print("handleSubmit")
        
        isFocused.wrappedValue = false
        let inputText = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        if inputText.isEmpty { return }
        
        var finalURLString: String
        if inputText.contains(".") && !inputText.contains(" ") {
            finalURLString = inputText.hasPrefix("https://") ? inputText : "https://" + inputText
        } else {
            if let encodedQuery = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                finalURLString = "https://www.google.com/search?q=" + encodedQuery
            } else { return }
        }
        
        statesManager.persistentStates.currentUrl = finalURLString
        $urlText.wrappedValue = finalURLString
        
        
    }
}



extension View {
    func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
        self.overlay(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ViewHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(ViewHeightKey.self, perform: onChange)
    }
}
