import SwiftUI
import FirebaseCore

@main
struct AutoPulseApp: App {
    @StateObject var auth = AuthViewModel()

    init() {
        FirebaseApp.configure()
        configureAppearance()
        NotificationService.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(auth)
                .preferredColorScheme(.dark)
        }
    }

    func configureAppearance() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppTheme.backgroundPrimary)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        // Tab Bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppTheme.backgroundSecondary)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
