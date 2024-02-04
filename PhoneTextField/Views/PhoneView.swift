//
//  PhoneView.swift
//  PhoneTextField
//
//  Created by Dmitry Kononchuk on 17.12.2023.
//  Copyright © 2023 Dmitry Kononchuk. All rights reserved.
//

import SwiftUI

struct PhoneView: View {
    // MARK: - Property Wrappers
    
    @State private var text = ""
    
    // MARK: - Private Properties
    
    private let placeholder: String
    private let countryCode: String
    private let title: String?
    private let error: String?
    private let errorLineLimit: Int
    private let isFocused: Bool
    private let submitLabel: SubmitLabel
    private let onSubmit: (() -> Void)?
    private let completion: (String) -> Void
    
    private let mask = "+X (XXX) XXX-XX-XX"
    
    private var internationalCode: String {
        "+" + countryCode
    }
    
    // MARK: - Initializers
    
    init(
        placeholder: String = "",
        countryCode: String = "1",
        text: String? = nil,
        title: String? = nil,
        error: String? = nil,
        errorLineLimit: Int = 2,
        isFocused: Bool,
        submitLabel: SubmitLabel = .return,
        onSubmit: (() -> Void)? = nil,
        completion: @escaping (String) -> Void
    ) {
        self.placeholder = placeholder
        self.countryCode = countryCode
        self.title = title
        self.error = error
        self.errorLineLimit = errorLineLimit
        self.isFocused = isFocused
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.completion = completion
        
        _text = State(wrappedValue: getOnlyNumbers(from: text ?? ""))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 4) {
                if let title = title {
                    Text(title)
                        .font(.custom("Seravek", size: 16))
                        .foregroundStyle(.black)
                        .opacity(0.8)
                }
                
                textField
            }
            
            if let error = error {
                Text(error)
                    .lineLimit(errorLineLimit)
                    .font(.custom("Seravek", size: 13))
                    .foregroundStyle(.red)
                    .offset(y: 65)
                    .padding(.horizontal, 8)
            }
        }
        .onReceive(text.publisher.collect()) { value in
            if isFocused {
                text = formattedNumber(
                    phone: text.isEmpty ? countryCode : String(value),
                    with: mask
                )
            } else {
                text = formattedNumber(
                    phone: text == internationalCode ? "" : String(value),
                    with: mask
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func formattedNumber(phone: String, with mask: String) -> String {
        var result = ""
        
        let numbers = getOnlyNumbers(from: phone)
        var index = numbers.startIndex
        
        for character in mask where index < numbers.endIndex {
            if character == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(character)
            }
        }
        
        return result
    }
    
    private func getOnlyNumbers(from text: String) -> String {
        text.replacingOccurrences(
            of: "[^0-9]", with: "",
            options: .regularExpression
        )
    }
    
    private func phoneChanged(to newValue: String) {
        guard newValue.count <= mask.count else { return }
        
        let numbers = getOnlyNumbers(from: newValue)
        
        if numbers == countryCode {
            completion("")
        } else {
            completion(numbers)
        }
    }
}

// MARK: - Ext. Configure views

extension PhoneView {
    private var textField: some View {
        TextField(
            placeholder,
            text: text.isEmpty
                ? .constant(isFocused ? internationalCode : "")
                : $text.onChange(phoneChanged)
        )
        .textFieldStyle(.roundedBorder)
        .onSubmit {
            onSubmit?()
        }
    }
}

// MARK: - Ext. Binding

private extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    PhoneView(
        placeholder: "Phone",
        text: "",
        title: "Phone",
        error: "A very long description of some error for the entered phone number",
        isFocused: true
    ) { number in
        print("Number: \(number)")
    }
    .padding()
}
