import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentGlow)
                            .frame(width: 90, height: 90)
                        Image(systemName: "car.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.accent)
                    }
                    Text("AutoPulse")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(String(localized: "Smart Vehicle Platform"))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.bottom, 48)

                // Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "Email"))
                            .font(.caption).fontWeight(.medium)
                            .foregroundStyle(AppTheme.textSecondary)
                        TextField("", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding()
                            .background(AppTheme.backgroundInput)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "Password"))
                            .font(.caption).fontWeight(.medium)
                            .foregroundStyle(AppTheme.textSecondary)
                        SecureField("", text: $password)
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding()
                            .background(AppTheme.backgroundInput)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 1))
                    }

                    if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .font(.caption)
                            .foregroundStyle(AppTheme.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: { auth.login(email: email, password: password) }) {
                        Group {
                            if auth.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(String(localized: "Sign In")).fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Divider
                    HStack {
                        Rectangle().fill(AppTheme.textMuted).frame(height: 0.5)
                        Text("or").font(.caption).foregroundStyle(AppTheme.textSecondary)
                        Rectangle().fill(AppTheme.textMuted).frame(height: 0.5)
                    }

                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = auth.prepareSignInWithApple()
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            auth.handleSignInWithApple(authorization)
                        case .failure(let error):
                            auth.errorMessage = error.localizedDescription
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                Spacer()

                HStack {
                    Text(String(localized: "Don't have an account?"))
                        .foregroundStyle(AppTheme.textSecondary)
                    Button(String(localized: "Sign Up")) { showRegister = true }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.accent)
                }
                .font(.subheadline)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView().environmentObject(auth)
        }
    }
}
