import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
        } else if auth.user != nil {
            MainTabView()
        } else {
            LoginView()
        }
    }
}
