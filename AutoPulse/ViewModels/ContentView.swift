//
//  ContentView.swift
//  AutoPulse
//
//  Created by Jeancarlo on 2026-05-29.
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.user != nil {
            Text("✅ Logged in as \(auth.user?.email ?? "")")
        } else {
            LoginView()
        }
    }
}

