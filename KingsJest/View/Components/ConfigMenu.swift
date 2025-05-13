//
//  ConfigMenu.swift
//  KingsJest
//
//  Created by Willys Oliveira on 13/05/25.
//

import SwiftUI

struct ConfigMenu: View {
    
    @Environment(\.openURL) var openURL
    
    @State private var isSoundOn: Bool = AudioManager.shared.isSoundEnabled
    @Binding var showNicknameAlert: Bool
    let formsUrl: String = "https://forms.gle/A1AwYC8LkspddA9x9"
    let helpPage: String = "https://mixolydian-hisser-233.notion.site/The-King-s-Jest-Support-1d2f1721b7f1804694e9f994c96614df"
    
    
    var body: some View {
        VStack(spacing: 20){
            Text("Settings")
                .font(.custom(appFonts.Libra.rawValue, size: 26))
                .foregroundStyle(Color.white1)
                .padding(.top, 24)
            
            HStack {
                Button {
                    showNicknameAlert = true
                    print(showNicknameAlert)
                } label: {
                    Text("Change Nickname")
                        .font(.custom(appFonts.Song.rawValue, size: 15))
                        .foregroundStyle(Color.white1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.white)

                }
            }
            .padding(.horizontal, 24)
            
            HStack {
                Text("Sound Effects")
                    .font(.custom(appFonts.Song.rawValue, size: 15))
                    .foregroundStyle(Color.white1)
                
                Spacer()
                
                Toggle("", isOn: $isSoundOn)
                    .tint(Color("red_light"))
                    .onChange(of: isSoundOn) { newValue in
                        AudioManager.shared.toggleSound(enabled: newValue)
                    }
                
            }
            .padding(.horizontal, 24)
            
            
            HStack {
                Button {
                    guard let url = URL(string: formsUrl) else { return }
                    openURL(url)

                } label: {
                    Text("Send Review")
                }
                .buttonStyle(CustomUIButtonStyle(
                    isDarkMode: true,
                    backgroundColor: Color("gray_config_menu"),
                    textColor: Color("red_light"),
                    fontSize: 15,
                    maxWidth: 165,
                    maxHeight: 31
                ))
                
                Spacer()
                
                Button {
                    guard let url = URL(string: helpPage) else { return }
                    openURL(url)
                } label: {
                    Text("Get Help")
                }
                .buttonStyle(CustomUIButtonStyle(
                    isDarkMode: true,
                    backgroundColor: Color("gray_config_menu"),
                    textColor: Color("red_light"),
                    fontSize: 15,
                    maxWidth: 165,
                    maxHeight: 31
                ))
                
            }
            .padding(.horizontal, 24)
            .padding(.vertical)
            
            Spacer()
        }
        .frame(width: 400, height: 260)
        .background{
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.grayLight)
                .overlay(
                    ZStack {
                        Image("SubtractHorizontal")
                    }
                )
        }
    }
}

#Preview {
    ConfigMenu(showNicknameAlert: .constant(true))
}
