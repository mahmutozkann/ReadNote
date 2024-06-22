//
//  ContentView.swift
//  ReadNote
//
//  Created by Mahmut Özkan on 19.06.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        Group{
            if authManager.isUserSignedIn{
                MainView()
            }else{
                SignIn()
            }
        }
    }
}

#Preview {
    ContentView()
}
