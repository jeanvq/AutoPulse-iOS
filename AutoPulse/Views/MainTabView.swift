import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label(String(localized: "Dashboard"), systemImage: "gauge.high")
                }

            VehiclesView()
                .tabItem {
                    Label(String(localized: "My Vehicles"), systemImage: "car.fill")
                }

            FuelView()
                .tabItem {
                    Label(String(localized: "Fuel"), systemImage: "fuelpump.fill")
                }

            MaintenanceView()
                .tabItem {
                    Label(String(localized: "Maintenance"), systemImage: "wrench.and.screwdriver.fill")
                }

            ProfileView()
                .tabItem {
                    Label(String(localized: "Profile"), systemImage: "person.fill")
                }
        }
    }
}
