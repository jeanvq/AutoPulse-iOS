import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        VStack(spacing: 0) {

            // Header
            VStack(spacing: 8) {
                Image(systemName: "car.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.blue)
                Text("AutoPulse")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Vehicle Health Manager")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 80)
            .padding(.bottom, 48)

            // Form
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

                if !auth.errorMessage.isEmpty {
                    Text(auth.errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }

                Button(action: {
                    auth.login(email: email, password: password)
                }) {
                    Group {
                        if auth.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign In").fontWeight(.semibold)
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

            HStack {
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)
                Button("Sign Up") {
                    showRegister = true
                }
                .fontWeight(.semibold)
            }
            .font(.subheadline)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(auth)
        }
    }
}//
//  LoginView.swift
//  AutoPulse
//
//  Created by Jeancarlo on 2026-05-29.
//

