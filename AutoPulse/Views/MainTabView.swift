import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.high")
                }

            VehiclesView()
                .tabItem {
                    Label("Vehicles", systemImage: "car.fill")
                }

            FuelView()
                .tabItem {
                    Label("Fuel", systemImage: "fuelpump.fill")
                }

            MaintenanceView()
                .tabItem {
                    Label("Maintenance", systemImage: "wrench.and.screwdriver.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
