//
//  ContentViewViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 14/04/25.
//

import SwiftUI

final class RootViewModel: ObservableObject {
    @Published var manager: MPCManager? = nil
    @Published var name: String = ""
    
    
    init(){
        name = UserDefaults.standard.string(forKey: "userNickname") ?? ""
    }
    
    deinit{
        UserDefaults.standard.set(name, forKey: "userNickname")
    }
    
    func createManagerIfNeeded() {
        guard !name.isEmpty else { return }
        
        let newManager = MPCManager(yourName: name)
        self.manager = newManager
    }
}
