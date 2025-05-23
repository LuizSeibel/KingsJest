//
//  TutorialTextStyle.swift
//  KingsJest
//
//  Created by Luiz Seibel on 23/05/25.
//

import SwiftUI

extension View{
    func tutorialTextStyle(color: TutorialTextStyle.StyleColor = .main) -> some View {
            self.modifier(TutorialTextStyle(color: color))
        }
}

struct TutorialTextStyle: ViewModifier {
    enum StyleColor {
        case main
        case secondary
    }
    
    var color: StyleColor
    
    func body(content: Content) -> some View {
        content
            .font(.custom(appFonts.Libra.rawValue, size: 18))
            .foregroundColor(color == .main ? .beigeDark : .redLight)
            .shadow(radius: 2)
    }
}
