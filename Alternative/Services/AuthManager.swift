//
//  FirebaseAuthService.swift
//  Alternative
//
//  Created by Евгений Мазурок on 13.03.2024.
//

import Foundation
import Firebase

class AuthManager {
        enum AuthState {
            case undefined, signedOut, signedIn
        }
        
        @Published var authState: AuthState = .undefined
        @Published var currentUser: FirebaseAuth.User?
        
        init() {
            Auth.auth().addStateDidChangeListener { auth, user in
                self.currentUser = user
                self.authState = user != nil ? .signedIn : .signedOut
            }
        }

    func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
}
