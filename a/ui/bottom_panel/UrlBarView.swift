//
//  UrlBarView.swift
//  a
//
//  Created by Tom on 11/13/25.
//

import SwiftUI

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
        .gesture(
            DragGesture(minimumDistance: 0) // minimumDistance: 0 lets it detect taps
                .onEnded { value in
                    // This code runs when the user lifts their finger.
                    handleGesture(value)
                }
        )
        .frame(height: settingsManager.settings.heightForLayer(layer: 1))
        .glassEffect(isFocused.wrappedValue ? .regular.interactive(): .clear.interactive(), in: .rect(cornerRadius: settingsManager.settings.cornerRadiusForLayer(layer: 1)))
        
        
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


//
//#Preview {
//    UrlBarView()
//}
