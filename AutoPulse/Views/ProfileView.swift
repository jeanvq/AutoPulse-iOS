import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    var userEmail: String {
        Auth.auth().currentUser?.email ?? "Unknown"
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            NavigationStack {
                ZStack {
                    AppTheme.backgroundPrimary.ignoresSafeArea()
                    List {
                        Section {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accentGlow)
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(AppTheme.accent)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("My Account")
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Text(userEmail)
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(AppTheme.backgroundCard)

                        Section("App") {
                            LabeledContent("Version", value: appVersion)
                            LabeledContent("Platform", value: "iOS")
                        }
                        .listRowBackground(AppTheme.backgroundCard)

                        Section {
                            Button(role: .destructive, action: { showLogoutAlert = true }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                }
                            }

                            Button(role: .destructive, action: { showDeleteAlert = true }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Delete Account")
                                }
                            }
                        }
                        .listRowBackground(AppTheme.backgroundCard)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .alert("Sign Out?", isPresented: $showLogoutAlert) {
                    Button("Sign Out", role: .destructive) { auth.logout() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You will be returned to the login screen.")
                }
                .alert("Delete Account?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        auth.deleteAccount { _ in }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will permanently delete your account and all your data. This action cannot be undone.")
                }
            }
        }
    }
}
