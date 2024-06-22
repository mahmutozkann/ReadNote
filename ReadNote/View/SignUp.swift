import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUp: View {
   
    @State private var usernameInput: String = ""
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var isLoading: Bool = false
    @State private var isSignedUp: Bool = false
    @State private var isButtonDisabled: Bool = true
    @State private var isErrorPresented: Bool = false

    var body: some View {
         
            NavigationStack {
                
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

                            VStack(spacing: 10) {
                                TextField("Username", text: $usernameInput, prompt: Text("Username").foregroundStyle(Color("TextFieldColor")))
                                    .padding()
                                    .background(Color.white)
                                    .foregroundStyle(Color("TextColor"))
                                    .border(Color.gray)
                                    .padding(.horizontal)
                                    .onChange(of: usernameInput, perform: { _ in
                                        validateFields()
                                    })
                                    

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
                                    

                                Spacer()

                                Button(action: {
                                    isLoading = true
                                    Auth.auth().createUser(withEmail: emailInput, password: passwordInput) { authData, error in
                                        isLoading = false
                                        if let error = error{
                                            print(error)
                                            isErrorPresented = true
                                            return
                                        }
                                        if let user = authData?.user{
                                            print("Signed success")
                                            isSignedUp = true
                                            saveUsername(userID: user.uid)
                                        }
                                    }
                                    
                                }) {
                                    if isLoading {
                                        ProgressView()
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.black)
                                            .cornerRadius(100)
                                    } else {
                                        Text("Sign Up")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.white)
                                            .background(isButtonDisabled ? Color("ButtonColor") : Color("DisabledButton"))
                                            .cornerRadius(100)
                                            
                                    }
                                }
                                .alert("Sign Up Error", isPresented: $isErrorPresented, actions: {
                                    Button("OK"){}
                                })
                                .disabled(isButtonDisabled)
                                .padding()
                                
                        }
                        
                        }
                        .scrollDismissesKeyboard(.immediately)
                        }
                    .navigationDestination(isPresented: $isSignedUp) {
                        SignIn()
                        
                    }
                    
               
                
            }
            
                    
    }
    
    private func validateFields(){
        isButtonDisabled = usernameInput.isEmpty || emailInput.isEmpty || passwordInput.isEmpty
    }
    
    private func saveUsername(userID: String){
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(["username": usernameInput, "email": emailInput]){error in
            if let error = error {
                print("Error saving username: \(error.localizedDescription)")
            }else{
                print("Username saved successfully")
            }
        }
    }
}

#Preview {
    SignUp()
}
