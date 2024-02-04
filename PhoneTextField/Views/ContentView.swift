//
//  ContentView.swift
//  PhoneTextField
//
//  Created by Dmitry Kononchuk on 17.12.2023.
//  Copyright © 2023 Dmitry Kononchuk. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Private Enums
    
    private enum Field {
        case phone
        case name
    }
    
    // MARK: - Property Wrappers
    
    @State private var name = ""
    
    @FocusState private var focusedField: Field?
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.indigo
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                PhoneView(
                    placeholder: "Phone",
                    title: "Phone",
                    isFocused: focusedField == .phone,
                    onSubmit: { focusedField = .name },
                    completion: { number in
                        print("Number \(number)")
                    }
                )
                .padding(.bottom, 34)
                .keyboardType(.numbersAndPunctuation)
                .focused($focusedField, equals: .phone)
                
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 8)
                    .focused($focusedField, equals: .name)
                
                Text("Some content")
            }
            .frame(width: 280)
            .padding()
        }
        .statusBarHidden()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
