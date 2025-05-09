//
//  BackButton.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import SwiftUI

struct CustomBackButton: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var labelText: String = "Back"
    var iconName: String = "back"
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(iconName)
                Text(labelText)
                    .fontWeight(.semibold)
                    .foregroundStyle(.yellowMain)
            }
        }
    }
}

#Preview {
    CustomBackButton()
}
