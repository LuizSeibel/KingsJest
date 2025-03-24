//
//  CustomListIndexView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import SwiftUI

struct CustomListIndexView: View {
    
    var label: String
    
    var labelButton1: String
    var labelButton2: String?
    
    var button1Closure: (() -> Void)
    var button2Closure: (() -> Void)?
    
    var button2Disable: Bool = false
    var isSmallStyle: Bool = false
    
    var body: some View {
        HStack{
            Text(label)
                .fontWeight(.semibold)
            
            Spacer()
            
            if let labelButton2 {
                CustomSelectButton(label: labelButton2, actionClosure: {}, disable: button2Disable)
                    .padding(.trailing, 8)
                    .frame(width: isSmallStyle ? 60 : 90)
            }
            
            Button(action: {
                button1Closure()
            }, label: {
                Text(labelButton1)
            })
            .buttonStyle(CustomSelectPlayerButton())
        }
        .padding(8)
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    
    CustomListIndexView(label: "Nickname", labelButton1: "Accept", labelButton2: "Ignore", button1Closure: {}, button2Closure: {})
    
    CustomListIndexView(label: "Nickname's Room", labelButton1: "Join", labelButton2: "0/8", button1Closure: {}, button2Disable: true, isSmallStyle: true)
}
