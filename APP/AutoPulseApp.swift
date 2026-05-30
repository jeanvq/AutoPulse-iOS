import SwiftUI
import FirebaseCore

@main
struct AutoPulseApp: App {
    @StateObject var auth = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
    }
}
