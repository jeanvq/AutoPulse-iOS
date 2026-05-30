import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 32)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }

                    Button(action: handleRegister) {
                        Group {
                            if auth.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account").fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    func handleRegister() {
        guard password == confirmPassword else {
            auth.errorMessage = "Passwords do not match."
            return
        }
        guard password.count >= 6 else {
            auth.errorMessage = "Password must be at least 6 characters."
            return
        }
        auth.register(email: email, password: password)
    }
}//
//  RegisterView.swift
//  AutoPulse
//
//  Created by Jeancarlo on 2026-05-29.
//

