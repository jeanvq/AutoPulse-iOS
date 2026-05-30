import SwiftUI
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading = false
    @Published var errorMessage = ""

    init() {
        // Detecta si ya hay sesión activa
        self.user = Auth.auth().currentUser
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.user = result?.user
                }
            }
        }
    }

    func register(email: String, password: String) {
        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.user = result?.user
                }
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        self.user = nil
    }
}//
//  AuthViewModel.swift
//  AutoPulse
//
//  Created by Jeancarlo on 2026-05-29.
//

