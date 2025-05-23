//
//  ContentViewViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 14/04/25.


import SwiftUI

final class RootViewModel: ObservableObject {
    @Published var manager: MPCManager? = nil
    @Published var name: String = "" {
        didSet {
            UserDefaults.standard.set(name, forKey: "userNickname")
        }
    }
    
    @Published var isFirstLaunch: Bool = true {
        didSet {
            UserDefaults.standard.set(isFirstLaunch, forKey: "isFirstLaunch")
        }
     }
    
    @Published var path = [Destination]()
    
    
    init(){
        name = UserDefaults.standard.string(forKey: "userNickname") ?? ""

        if UserDefaults.standard.object(forKey: "isFirstLaunch") == nil {
            isFirstLaunch = true
        } else {
            isFirstLaunch = false
        }
    }
    
    
    func createManagerIfNeeded() {
        guard !name.isEmpty else { return }
        
        let newManager = MPCManager(yourName: name)
        self.manager = newManager
    }
}
