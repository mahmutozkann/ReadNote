import SwiftUI
import FirebaseAuth
import FirebaseFirestore



struct ProfileView: View {
    
    @State private var isSignedOut: Bool = false
    @State private var username: String = ""
    @State private var bookNotes: [BookNote] = []
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            VStack {
                
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 3))
                        .shadow(radius: 10)
                        .padding(.top, 50)
                    
                    Text("Hi \(username)!")
                        .font(.title)
                        .padding()
                
                if bookNotes.isEmpty {
                    VStack{
                        Text("Henüz bir not kaydetmediniz!")
                            .font(.title2)
                            .foregroundColor(Color.primary)
                            .padding()
                        Spacer()
                    }
                }else{
                    List(bookNotes){note in
                        VStack(alignment: .leading){
                            Text(note.title)
                                .font(.title2)
                            Text(note.author)
                                .font(.title3)
                            Text("Page: \(note.pageNumber)")
                                .font(.subheadline)
                            Text(note.quote)
                                .font(.body)
                        }
                        .swipeActions(edge: .trailing){
                            Button(role: .destructive){
                                deleteNote(note)
                            }label: {
                                Label("Delete",systemImage: "trash")
                            }
                        }
                        .padding()
                    }
                }
                    
                    
                    
                    Spacer()
                    
                    Button(action: {
                        
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            isSignedOut = true
                            authManager.isUserSignedIn = false
                        }catch let signOutError as NSError {
                            print("Error signing out %@", signOutError)
                        }
                    }) {
                        Label("Sign Out",systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("DisabledButton"))
                            .cornerRadius(100)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
            }
            
            .navigationDestination(isPresented: $isSignedOut) {
                SignIn()
            }
        }
        .onAppear{
            fetchUsername()
            fetchBookNotes()
        }
    }
    
    private func fetchUsername(){
            
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in!")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists{
                if let data = document.data(), let fetchedUsername = data["username"] as? String{
                    username = fetchedUsername
                }else{
                    print("Username field does not exist")
                }
            }else{
                print("Document does not exist")
            }
        }
    
    }
    
    private func deleteNote(_ note: BookNote) {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("No user is logged in!")
                return
            }
            
            let db = Firestore.firestore()
        db.collection("users").document(userID).collection("bookNotes").document(note.id!).delete { error in
                if let error = error {
                    print("Error deleting note: \(error.localizedDescription)")
                } else {
                    bookNotes.removeAll { $0.id == note.id }
                }
            }
        }

    private func fetchBookNotes() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("No user is logged in!")
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(userID).collection("bookNotes").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching book notes: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                bookNotes = documents.compactMap { document -> BookNote? in
                    var bookNote = try? document.data(as: BookNote.self)
                    bookNote?.id = document.documentID
                    return bookNote
                }
            }
        }
    
}

#Preview {
    ProfileView()
}
