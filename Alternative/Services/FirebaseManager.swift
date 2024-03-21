import Firebase
import Combine

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    @Published public var altushkas:[Altushka] = []
    @Published public var currentUser: MyUser?
    @Published public var isAuth:Bool = false
    private var myUser: MyUser?
    
    var user: MyUser? {
        return currentUser
    }
    
    func getIsAuth() -> Bool{
        return isAuth
    }
    
    func loginUser(email: String, password: String) {
        let userRef = db.collection("users").whereField("email", isEqualTo: email)
        userRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting user documents: \(error)")
                self.isAuth = false
            } else {
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("User with email \(email) already exists")
                    let newUser = MyUser(name: "", email: email, age: 0, weight: 0, alcoholStage: 0, isConfirmed: "false", score: 0)
                    self.currentUser = newUser
                    self.isAuth = true
                    print(self.isAuth)
                } else {
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let user = result?.user {
                            let newUser = MyUser(name: user.displayName ?? "", email: email, age: 0, weight: 0, alcoholStage: 0, isConfirmed: "false", score: 0)
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
    
    func addOrder(order: Order) {
        let _ = db.collection("orders").document(order.user).setData([
            "deliveryDate": order.deliveryDate,
            "altushka": order.altushka,
            "user": order.user
        ])
    }
    
    func addDataToUser(field: String, value: Any) {
        self.getUserByEmail { user in
            if let user = user {
                self.myUser = user
            }
            let query = self.db.collection("users").whereField("email", isEqualTo: self.myUser!.email)
            
            query.getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        self.currentUser?.isConfirmed = "true"
                        let documentRef = self.db.collection("users").document(document.documentID)
                        documentRef.updateData([field: value]) { error in
                            if let error = error {
                                print("Error updating field: \(error)")
                            } else {
                                print("Field updated successfully")
                            }
                        }
                    }
                }
            }
        }

    }

    func updateAltushkaStatus(name: String, status:String) -> Void{
        let query = self.db.collection("girls").whereField("name", isEqualTo: name)
        
        query.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let documentRef = self.db.collection("girls").document(document.documentID)
                    documentRef.updateData(["isFree": status]) { error in
                        if let error = error {
                            print("Error updating field: \(error)")
                        } else {
                            print("Field updated successfully")
                        }
                    }
                }
            }
        }
        self.fetchAltushkas { altushkas in
            DispatchQueue.main.async {
                self.altushkas = altushkas
            }
        }
    }
    
    func checkIfUserHaveOrder(completion: @escaping (Bool) -> Void) {

        getUserByEmail { user in
            if let user = user {
                
                self.myUser = user
            }
            let userRef = self.db.collection("orders").whereField("user", isEqualTo: String(self.myUser!.email))
            userRef.getDocuments { snapshot, error in
                if let documents = snapshot?.documents, documents.isEmpty {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    func getUserByEmail(completion: @escaping (MyUser?) -> Void) {
        var result: MyUser?
        guard let currentUserEmail = currentUser?.email else {
            completion(nil)
            return
        }

        let userRef = db.collection("users").whereField("email", isEqualTo: currentUserEmail)
        
        userRef.getDocuments { snapshot, error in
            if error != nil {
                completion(nil)
                return
            }
            
            for document in snapshot!.documents {
                let data = document.data()
                result = MyUser(name: data["name"] as? String ?? "", email: data["email"] as? String ?? "", age: data["age"] as? Int ?? 0, weight: data["weight"] as? Int ?? 0, alcoholStage: data["alcoholStage"] as? Int ?? 0, isConfirmed: data["isConfirmed"] as? String ?? "", score: data["score"] as? Int ?? 0)
            }
            
            completion(result)
        }
    }


    
    func createUser(_ user: MyUser) {
        let _ = db.collection("users").document(user.email).setData([
            "name": user.name,
            "email": user.email,
            "age": user.age,
            "weight": user.weight,
            "alcoholStage": user.alcoholStage,
            "isConfirmed": user.isConfirmed,
            "score": user.score
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                // Handle success
            }
        }
    }
    
    func fetchAltushkas(completion: @escaping ([Altushka]) -> Void) {
        getAllAltushkas() { altushkas in
            DispatchQueue.main.async {
                self.altushkas = altushkas
            }
        }
        completion(altushkas)
    }


    func getAllAltushkas(completion: @escaping ([Altushka]) -> Void) {
        var altushkas: [Altushka] = []
        
        self.db.collection("girls").whereField("isFree", isEqualTo: "true").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    altushkas.append(Altushka(name: data["name"] as? String ?? "", tags: data["tags"] as? String ?? "", photo: data["photo"] as? String ?? "", isFree: data["isFree"] as? Bool ?? true))
                }
            }
            completion(altushkas)
        }
    }
    
    func getAllOrders(completion: @escaping (Order) -> Void){
        getUserByEmail { user in
            if let user = user {
                self.myUser = user
            }
            var result: Order = Order(deliveryDate: "", altushka: "", user: "")
            self.db.collection("orders").whereField("user", isEqualTo: String(self.myUser!.email)).getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        let data = document.data()
                        result = Order(deliveryDate: data["deliveryDate"]  as! String, altushka: data["altushka"]  as! String, user: (data["user"]  as! String))
                    }
                }
                completion(result)
            }
        }
    }

    func getAltushkaByName(name:String, completion: @escaping (Altushka) -> Void) {
        var result: Altushka = Altushka(name: "", tags: "", photo: "", isFree: true)
        self.db.collection("girls").whereField("name", isEqualTo: name).getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    result = Altushka(name: data["name"] as? String ?? "", tags: data["tags"] as? String ?? "", photo: data["photo"] as? String ?? "", isFree: data["isFree"] as? Bool ?? true)
                }
            }
            completion(result)
        }
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
    
    func deleteOrder(){
        if let user = user {
            
            self.myUser = user
        }
        let query = self.db.collection("orders").whereField("user", isEqualTo: self.myUser!.email)
        
        query.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let documentRef = self.db.collection("orders").document(document.documentID)
                    documentRef.delete(){ error in
                        if let error = error {
                            print("Error updating field: \(error)")
                        } else {
                            print("Field updated successfully")
                        }
                    }
                }
            }
        }
    }
}
