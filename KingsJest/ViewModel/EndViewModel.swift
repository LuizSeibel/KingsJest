//
//  EndViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/03/25.
//

import Foundation
import MultipeerConnectivity

class EndViewModel: ObservableObject {
    @Published var goToMainMenu: Bool = false
    
}

extension EndViewModel {
    func toMainMenu() {
        goToMainMenu = true
    }
}
