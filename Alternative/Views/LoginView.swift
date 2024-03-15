import SwiftUI
import Firebase

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text(isSignUp ? "Sign Up" : "Log In")
                .font(.title)
                .padding()
            
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if isSignUp {
                Button("Sign Up") {
                    signUp()
                }
                .padding()
            } else {
                Button("Log In") {
                    logIn()
                }
                .padding()
            }
            
            Button(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up") {
                isSignUp.toggle()
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                print("User signed up successfully")
            }
        }
    }
    
    func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                print("User logged in successfully")
                // Navigate to the next screen or perform any necessary actions
            }
        }
    }
}
