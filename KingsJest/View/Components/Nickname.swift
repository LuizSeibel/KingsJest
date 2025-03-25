//
//  Nickname.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import SwiftUI
import UIKit

struct Nickname: View {
    @Binding var text: String
    @State var placeholder: String = "Nickname"
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(.gray1))
                .frame(width: 25, height: 25)
                .overlay(
                    Image("touca")
                        .resizable()
                        .scaledToFit()
                        .padding(3)
                )
            
            CustomUITextField(placeholder: placeholder, text: $text)
                .padding(0)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.systemGray4))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("UIBackground1"))
        )
        .frame(maxWidth: .infinity, maxHeight: 5)
    }
}

#Preview {
    Nickname(text: .constant(""))
}

struct CustomUITextField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String
    
    var placeholderColor: UIColor = .gray
    var font: UIFont = .systemFont(ofSize: 14, weight: .bold)
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.text = text
        textField.font = font
        textField.textColor = UIColor.gray1
        textField.autocorrectionType = .no
        textField.adjustsFontForContentSizeCategory = false
        textField.returnKeyType = .done
        textField.addTarget(context.coordinator, action: #selector(Coordinator.dismissKeyboard), for: .editingDidEndOnExit)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomUITextField

        init(_ textField: CustomUITextField) {
            self.parent = textField
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        @objc func dismissKeyboard(_ sender: UITextField) {
            sender.resignFirstResponder()
        }
    }
}
