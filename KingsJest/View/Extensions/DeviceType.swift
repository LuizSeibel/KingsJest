//
//  devicesSizes.swift
//  KingsJest
//
//  Created by Luiz Seibel on 05/05/25.
//

import UIKit

enum DeviceType {
    case iPhone, iPadMini, iPad

    static func current() -> DeviceType {
        let interfaceIdiom = UIDevice.current.userInterfaceIdiom
        let screen = UIScreen.main.bounds
        let minDimension = min(screen.width, screen.height)

        switch interfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return minDimension < 800 ? .iPadMini : .iPad
        default:
            return .iPhone
        }
    }
}
