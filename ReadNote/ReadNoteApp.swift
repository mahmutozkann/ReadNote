//
//  ReadNoteApp.swift
//  ReadNote
//
//  Created by Mahmut Özkan on 11.06.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth




@main
struct ReadNoteApp: App {
    @StateObject private var authManager = AuthManager()
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        
        WindowGroup {
            
                ContentView()
                    .environmentObject(authManager)
                    .onAppear{
                        authManager.checkUserState()
                    }
                    
           
            
        }
    }
}

class AuthManager: ObservableObject {
    @Published var isUserSignedIn: Bool = false
    
    func checkUserState(){
        if Auth.auth().currentUser != nil {
            isUserSignedIn = true
        }else{
            isUserSignedIn = false
        }
    }
}
