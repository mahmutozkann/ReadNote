import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?

    init() {
        checkUser()
    }

    func checkUser() {
        self.user = Auth.auth().currentUser
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.user = result?.user
        }
    }

    func signUp(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            guard let user = result?.user else { return }
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.user = user
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }
}
