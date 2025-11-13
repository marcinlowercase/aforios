//
//  URLBarView.swift
//  a
//
//  Created by Tom on 11/12/25.
//

import SwiftUI
import UIKit

struct URLBarView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    // @Binding allows the parent view (ContentView) to pass down a state
    // variable that this view can read AND write to.
    @Binding var urlText: String
    
    // The parent view will also pass down its FocusState.
    var isFocused: FocusState<Bool>.Binding
    
    var onURLSubmit: (String) -> Void
    
    var body: some View {
        let settings = settingsManager.settings
        
        HStack {
            ZStack {
                // The TextField is always here, but it's invisible when not focused.
                // This makes it always ready to receive focus.
                TextField("Search or type URL", text: $urlText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .focused(isFocused)
                    .onSubmit { handleSubmit() }
                    .submitLabel(.go)
                    .opacity(isFocused.wrappedValue ? 1 : 0) // Show only when focused
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { notification in
                        if let textField = notification.object as? UITextField {
                            // Tell that text field to select all of its content.
                            textField.selectAll(nil)
                        }
                    }
                
                // Unfocused View: Display the clean domain name.
                if !isFocused.wrappedValue, let domain = domain(from: urlText) {
                    Text(domain)
                        .font(.body) // Use a standard font
                        .foregroundColor(.primary) // Adapts to light/dark mode
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(height: settings.heightForLayer(layer: 1))
            .glassEffect(isFocused.wrappedValue ? .regular.interactive(): .clear.interactive(), in: .rect(cornerRadius: settings.cornerRadiusForLayer(layer: 1)))
            .onTapGesture {
                isFocused.wrappedValue = true // Tapping the bar requests focus
            }
            
        }
        .padding(settings.paddingDp)
        // This is the magic: Animate any changes that happen when 'isFocused' changes.
        .animation(.smooth, value: isFocused.wrappedValue)
        .onChange(of: isFocused.wrappedValue) {
            // We need to get the latest value directly from the binding.
            if !isFocused.wrappedValue {
                // When focus is lost, reset the text field's content
                // back to the original URL from the web view.
                // This logic remains the same, but how we check the condition is slightly different.
            }
        }
    }
    
    private func handleSubmit() {
        // The submission logic remains the same as before.
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
        onURLSubmit(finalURLString)
    }
}
