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
    
    func stopRecording(){
        guard let rootVC = UIApplication.shared.rootViewController() else {
            print("Não foi possível encontrar o rootViewController.")
            return
        }
        
        // Para a gravação e exibe o preview, que contém o botão de "Share"
        ReplayKitManager.shared.stopRecording(presenter: rootVC) { error in
            if let error = error {
                print("Erro ao parar gravação:", error.localizedDescription)
            } else {
                print("Gravação finalizada e preview exibido.")
            }
        }
    }
    
    func showRecording(){
        guard UIApplication.shared.rootViewController() != nil else {
            print("Não foi possível encontrar o rootViewController.")
            return
        }
        ReplayKitManager.shared.showPreview()
    }
}
