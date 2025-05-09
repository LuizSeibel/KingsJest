//
//  CustomFonts.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import UIKit
import CoreText

func registerFont(withName name: String, fileExtension: String) {
    guard let fontURL = Bundle.main.url(forResource: name, withExtension: fileExtension) else { return }
    
    guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
          let font = CGFont(fontDataProvider) else { return }
    
    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterGraphicsFont(font, &error) {
        print("Erro ao registrar fonte: \(error.debugDescription)")
    }
}

enum appFonts: String{
    case Libra = "ø"
    case Song = "STSongti-TC-Bold"
}
