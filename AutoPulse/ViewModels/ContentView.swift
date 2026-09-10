import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.user != nil {
            MainTabView()
        } else {
            LoginView()
        }
    }
}
