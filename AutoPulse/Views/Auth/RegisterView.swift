import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()

            NavigationStack {
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accentGlow)
                                .frame(width: 80, height: 80)
                            Image(systemName: "car.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(AppTheme.accent)
                        }
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Join AutoPulse today")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.bottom, 40)

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
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
                            Text("Password")
                                .font(.caption).fontWeight(.medium)
                                .foregroundStyle(AppTheme.textSecondary)
                            SecureField("", text: $password)
                                .foregroundStyle(AppTheme.textPrimary)
                                .padding()
                                .background(AppTheme.backgroundInput)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 1))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirm Password")
                                .font(.caption).fontWeight(.medium)
                                .foregroundStyle(AppTheme.textSecondary)
                            SecureField("", text: $confirmPassword)
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
                            .background(AppTheme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.bottom, 32)
                }
            }
        }
    }

    func handleRegister() {
        auth.errorMessage = ""
        
        // Validar email
        guard isValidEmail(email) else {
            auth.errorMessage = "Please enter a valid email address."
            return
        }
        
        // Validar password
        guard password.count >= 6 else {
            auth.errorMessage = "Password must be at least 6 characters."
            return
        }
        
        // Validar confirmación
        guard password == confirmPassword else {
            auth.errorMessage = "Passwords do not match."
            return
        }
        
        auth.register(email: email, password: password)
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}
