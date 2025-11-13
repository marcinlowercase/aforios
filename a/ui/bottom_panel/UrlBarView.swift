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
        let settings = settingsManager.settings

        ZStack {
            // UrlBar not focus -> invisible but still there to receive the tap event
            TextField("Search or type URL", text: $urlText)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .focused(isFocused)
                .onSubmit { handleSubmit() }
                .submitLabel(.go)
                .frame(height: settings.heightForLayer(layer: 1))
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
                    .foregroundColor(.primary)
                    .onTapGesture {
                        isFocused.wrappedValue = true
                        print("Tap on domain")
                    }
                    .opacity(isFocused.wrappedValue ? 0 : 1)
                
            }
        }
        .frame(height: settings.heightForLayer(layer: 1))
        .glassEffect(isFocused.wrappedValue ? .regular.interactive(): .clear.interactive(), in: .rect(cornerRadius: settings.cornerRadiusForLayer(layer: 1)))
        .onTapGesture {
            isFocused.wrappedValue = true
        }
        .onAppear{
            $urlText.wrappedValue = statesManager.states.currentUrl
        }
        .onChange(of: statesManager.states.currentUrl) { oldValue, newValue in
            urlText = newValue
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
        
        statesManager.states.currentUrl = finalURLString
        $urlText.wrappedValue = finalURLString
        
        
    }
}


//
//#Preview {
//    UrlBarView()
//}
