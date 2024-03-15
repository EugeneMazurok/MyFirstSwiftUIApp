import Firebase
import Combine

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private var currentUser: User?

    @Published var isAuth:Bool = false

    var user: User? {
        return currentUser
    }
    
    func loginUser(email: String, password: String, isAuthStateObserver: PassthroughSubject<Bool, Never>) {
        let userRef = db.collection("users").whereField("email", isEqualTo: email)
        userRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting user documents: \(error)")
                self.isAuth = false
            } else {
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("User with email \(email) already exists")
                    self.isAuth = true
                    print(self.isAuth)
                } else {
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let user = result?.user {
                            let newUser = User(name: user.displayName ?? "", email: user.email ?? "", age: 0, weight: 0, alcoholStage: 0, jobId: 0)
                            self.currentUser = newUser
                            self.createUser(newUser)
                            print("User created successfully")
                            self.isAuth = true
                        } else if let error = error {
                            print("Error signing in: \(error)")
                            self.isAuth = false
                        }
                    }
                }
            }
        }
    }
    
    func createUser(_ user: User) {
        let _ = db.collection("users").document(user.id).setData([
            "name": user.name,
            "email": user.email
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                // Handle success
            }
        }
    }

    func getAllAltushkas() -> AnyPublisher<[Altushka], Error> {
        return Future<[Altushka], Error> { promise in
            self.db.collection("альтушка").getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let altushkas = snapshot?.documents.compactMap { document -> Altushka? in
                        let data = document.data()
                        return Altushka(id: document.documentID, name: data["name"] as? String ?? "", tags: data["tags"] as? [String] ?? [""], photo: data["photo"] as? String ?? "", isFree: data["is_free"] as? Bool ?? true)
                    }
                    promise(.success(altushkas ?? []))
                }
            }
        }.eraseToAnyPublisher()
    }

    func deleteAltushka(withId altushkaId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection("альтушка").document(altushkaId).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }

    // Другие методы для работы с базой данных Firebase могут быть добавлены сюда
}
