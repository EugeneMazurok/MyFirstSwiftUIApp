import Firebase

class AuthManager {
    let db = Firestore.firestore()
    
    func signIn(email: String, password: String, isAuthenticated: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                isAuthenticated(false)
            } else {
                if let user = Auth.auth().currentUser {
                    let usersRef = self.db.collection("users").whereField("email", isEqualTo: user.email ?? "")
                    usersRef.getDocuments { snapshot, error in
                        if let error = error {
                            isAuthenticated(false)
                        } else if snapshot?.documents.isEmpty ?? true {
                            self.db.collection("users").document(user.uid).setData([
                                "age": 0,
                                "email": user.email ?? "",
                                "gender": "",
                                "id": user.uid,
                                "name": "",
                                "role":""
                            ]) { error in
                                if let error = error {
                                    isAuthenticated(false)
                                } else {

                                    isAuthenticated(true)
                                }
                            }
                        } else {
                            // User already exists, perform necessary actions
                            isAuthenticated(true)
                        }
                    }
                }
            }
        }
    }
}
