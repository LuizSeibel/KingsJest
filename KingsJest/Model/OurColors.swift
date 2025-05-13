//
//  OurColor.swift
//  KingsJest
//
//  Created by Luiz Seibel on 13/05/25.
//

import Foundation
import UIKit

enum ourColors: Int, Codable, CaseIterable {
    case yellow = 1
    case blue = 2
    case orange = 3
    case black = 4
    case pink = 5
    case purple = 6
    case red = 7
    case green = 8
    case none = 0
}

extension ourColors{
    static func returnColors(color: ourColors) -> [UIColor]{
        switch color{
        case .yellow:
            return [
                    UIColor(hex: "#5D3F0B"),
                    UIColor(hex: "#F59A00"),
                    UIColor(hex: "#FFB000"),
                    UIColor(hex: "#FADA93"),
                    UIColor(hex: "#FFF3DD")
            ]
        case .blue:
           return [
                    UIColor(hex: "#01278E"),
                    UIColor(hex: "#326BFF"),
                    UIColor(hex: "#85B7FF"),
                    UIColor(hex: "#C4DEFF"),
                    UIColor(hex: "#ECFDFF")
            ]
        case .orange:
            return [
                    UIColor(hex: "#401800"),
                    UIColor(hex: "#FF5229"),
                    UIColor(hex: "#FF9F18"),
                    UIColor(hex: "#FFBF4E"),
                    UIColor(hex: "#FFEBDB")
            ]
        case .black:
            return [
                    UIColor(hex: "#131313"),
                    UIColor(hex: "#B1B3B3"),
                    UIColor(hex: "#DEE0E0"),
                    UIColor(hex: "#FCFFFF")
            ]
        case .pink:
            return [
                    UIColor(hex: "#66053E"),
                    UIColor(hex: "#FE40B9"),
                    UIColor(hex: "#FE79CB"),
                    UIColor(hex: "#FFADDD"),
                    UIColor(hex: "#F6DBE0")
            ]
        case .purple:
            return [
                    UIColor(hex: "#44005C"),
                    UIColor(hex: "#CD57FF"),
                    UIColor(hex: "#DE89FF"),
                    UIColor(hex: "#E9B7FF"),
                    UIColor(hex: "#EFD5FC")
            ]
        case .red:
            return [
                    UIColor(hex: "#660808"),
                    UIColor(hex: "#FA3838"),
                    UIColor(hex: "#FF5B5C"),
                    UIColor(hex: "#FF9294"),
                    UIColor(hex: "#FEC8CC")
                    ]
        case .green:
            return [
                    UIColor(hex: "#00470B"),
                    UIColor(hex: "#12A317"),
                    UIColor(hex: "#42FF47"),
                    UIColor(hex: "#9CFF9D"),
                    UIColor(hex: "#CDFFCA")
            ]
        case .none:
            return [UIColor.clear]
        }
    }
}
