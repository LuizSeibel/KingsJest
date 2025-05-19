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
    @Binding var showConfigMenu: Bool
    let formsUrl: String = "https://forms.gle/A1AwYC8LkspddA9x9"
    let helpPage: String = "https://mixolydian-hisser-233.notion.site/The-King-s-Jest-Support-1d2f1721b7f1804694e9f994c96614df"
    
    
    var body: some View {
        ZStack (alignment: .topTrailing) {
            VStack{
                
                Spacer()

                Text("Settings")
                    .font(.custom(appFonts.Libra.rawValue, size: 26))
                    .foregroundStyle(Color.beigeMain)
                
                Spacer()
                
                VStack (spacing: 16){
                    HStack {
                        Button {
                            withAnimation{
                                showNicknameAlert = true
                            }
                            print(showNicknameAlert)
                        } label: {
                            Text("Change Nickname")
                                .font(.system(size: 15, weight: .semibold, design: .serif))
                                .foregroundStyle(Color.beigeMain)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.beigeMain)
                            
                        }
                    }
                    
                    HStack {
                        Text("Sound Effects")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.beigeMain)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isSoundOn)
                            .tint(Color.redLight)
                            .onChange(of: isSoundOn) { newValue in
                                AudioManager.shared.toggleSound(enabled: newValue)
                            }
                        
                    }
                }
                
                Spacer()
                
                HStack {
                    Button {
                        guard let url = URL(string: formsUrl) else { return }
                        openURL(url)
                        
                    } label: {
                        Text("Send Review")
                    }
                    .buttonStyle(CustomUIButtonStyle(
                        isDarkMode: true,
                        backgroundColor: Color.beigeDark,
                        textColor: Color.redLight,
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
                        backgroundColor: Color.beigeDark,
                        textColor: Color("red_light"),
                        fontSize: 15,
                        maxWidth: 165,
                        maxHeight: 31
                    ))
                    
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(width: 400, height: 278)
            .background{
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryRedDark)
                    .overlay(
                        ZStack {
                            Image("SubtractHorizontal")
                                .foregroundStyle(Color.redDark)
                        }
                    )
            }
            
            Button {
                withAnimation{
                    showConfigMenu = false
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.beigeMain)
                    .fontWeight(.bold)
                    .opacity(0.7)
                    .padding(.top, 46)
                    .padding(.trailing, 24)
            }
        }
    }
}

#Preview {
    ConfigMenu(showNicknameAlert: .constant(true), showConfigMenu: .constant(true))
}
