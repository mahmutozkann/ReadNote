//
//  MainView.swift
//  ReadNote
//
//  Created by Mahmut Özkan on 13.06.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        
        TabView{
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .navigationBarBackButtonHidden(true)
    }
        
        
}

#Preview {
    MainView()
}
