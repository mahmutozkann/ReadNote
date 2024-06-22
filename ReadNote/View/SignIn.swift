import SwiftUI
import FirebaseAuth

struct SignIn: View {
    
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var isLoading: Bool = false
    @State private var isSignedIn: Bool = false
    @State private var isButtonDisabled: Bool = true
    @State private var alertMessage: String = ""
    @State private var showAlertPass: Bool = false
    @State private var showAlertSign: Bool = false

    var body: some View {
        NavigationStack{
            
                VStack {
                    ScrollView{
                        Image("readNoteIconBW")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("BorderColor"), lineWidth: 4))
                            .frame(width: 200, height: 200)
                            .shadow(radius: 10)
                            .padding()

                        VStack(spacing: 20) {
                            TextField("", text: $emailInput, prompt: Text("E-mail").foregroundStyle(Color("TextFieldColor")))
                                .padding()
                                .background(Color.white)
                                .foregroundStyle(Color("TextColor"))
                                .border(Color.gray)
                                .padding(.horizontal)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .onChange(of: emailInput, perform: { _ in
                                    validateFields()
                                })

                            SecureField("Password", text: $passwordInput, prompt: Text("Password").foregroundStyle(Color("TextFieldColor")))
                                .padding()
                                .background(Color.white)
                                .foregroundStyle(Color("TextColor"))
                                .border(Color.gray)
                                .padding(.horizontal)
                                .onChange(of: passwordInput, perform: { _ in
                                    validateFields()
                                })

                            HStack {
                                Spacer()
                                Button(action: {
                                    // Forgot Password action
                                    sendPasswordReset()
                                }, label: {
                                    Text("Forgot Password?")
                                        .foregroundColor(Color("TextButton"))
                                        .padding()
                                })
                                
                            }
                            .alert(isPresented: $showAlertPass, content: {
                                Alert(title: Text("Forgot Password"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                            })
                        }
                        .padding()

                        

                        Button(action: {
                            isLoading = true
                            Auth.auth().signIn(withEmail: emailInput, password: passwordInput) { authResult, error in
                                if let error = error {
                                    isLoading = false
                                    showAlertSign = true
                                    print(error)
                                }
                                if let authResult = authResult{
                                    print(authResult)
                                    isSignedIn = true
                                }
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(100)
                                    .padding()
                            } else {
                                Label("Sign In", systemImage: "rectangle.portrait.and.arrow.right")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(isButtonDisabled ? Color("ButtonColor") : Color("DisabledButton"))
                                    .cornerRadius(100)
                                    .padding()
                            }
                        }
                        .alert("E-mail or Password failed!", isPresented: $showAlertSign, actions: {
                            Button("OK"){}
                        })
                        .disabled(isButtonDisabled)
                        .padding(.horizontal)
                        

                        HStack {
                            Text("Don't you have an account?")
                                .foregroundColor(.gray)
                            NavigationLink(destination: SignUp()) {
                                Text("Sign Up")
                                    .foregroundColor(Color("TextButton"))
                                    .padding()
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    
                }
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $isSignedIn) {
                    MainView()
            }
            
        }
    }
    
    private func validateFields(){
        isButtonDisabled = emailInput.isEmpty || passwordInput.isEmpty
    }
    
    private func sendPasswordReset() {
            let alert = UIAlertController(title: "Reset Password", message: "Enter your email address to reset your password.", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Email"
                textField.keyboardType = .emailAddress
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
                if let email = alert.textFields?.first?.text, !email.isEmpty {
                    Auth.auth().sendPasswordReset(withEmail: email) { error in
                        if let error = error {
                            self.alertMessage = "Error sending reset email: \(error.localizedDescription)"
                        } else {
                            self.alertMessage = "Password reset email sent successfully."
                        }
                        self.showAlertPass = true
                    }
                } else {
                    self.alertMessage = "Please enter a valid email address."
                    self.showAlertPass = true
                }
            }))
            
            // Present the alert
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    
}

#Preview {
    SignIn()
}
