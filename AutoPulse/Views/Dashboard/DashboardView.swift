import SwiftUI

struct DashboardView: View {
    @StateObject private var vehiclesVm = VehiclesViewModel()
    @StateObject private var fuelVm = FuelViewModel()
    @StateObject private var maintenanceVm = MaintenanceViewModel()
    @StateObject private var weather = WeatherService()
    @State private var showAIScanner = false
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedVehicle: Vehicle?
    @State private var healthScore: HealthScore?
    @State private var animatedScore: Double = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            NavigationStack {
                ZStack {
                    AppTheme.backgroundPrimary.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            pickerSection
                            contentSection
                        }
                        .padding(.top)
                    }
                }
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showAIScanner = true }) {
                            Image(systemName: "cpu.fill")
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                }
                .sheet(isPresented: $showAIScanner) {
                    AIScannerView()
                }
                .onAppear(perform: onAppear)
                .onChange(of: vehiclesVm.vehicles) { _, vehicles in
                    if self.selectedVehicle == nil, let first = vehicles.first {
                        self.selectVehicle(first)
                    }
                }
                .onChange(of: fuelVm.records) { _, _ in recalculate() }
                .onChange(of: maintenanceVm.records) { _, _ in recalculate() }
            }
        }
    }

    var pickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vehiclesVm.vehicles) { vehicle in
                    Button(action: { selectVehicle(vehicle) }) {
                        Text(vehicle.nickname.isEmpty ? "\(vehicle.make) \(vehicle.model)" : vehicle.nickname)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedVehicle?.id == vehicle.id ? AppTheme.accent : AppTheme.backgroundCard)
                            .foregroundStyle(selectedVehicle?.id == vehicle.id ? .white : AppTheme.textSecondary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(selectedVehicle?.id == vehicle.id ? AppTheme.accent : AppTheme.textMuted, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    var contentSection: some View {
        if vehiclesVm.vehicles.isEmpty {
            emptyStateView
        } else if let vehicle = selectedVehicle {
            WeatherBanner(alert: weather.weatherAlert)
            VehicleDashboardContent(
                vehicle: vehicle,
                healthScore: healthScore,
                animatedScore: animatedScore,
                fuelCount: fuelVm.records.count,
                maintenanceCount: maintenanceVm.records.count,
                totalFuelSpent: fuelVm.totalSpent
            )
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGlow)
                    .frame(width: 80, height: 80)
                Image(systemName: "car.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppTheme.accent)
            }
            Text("No vehicles yet")
                .font(.title3).fontWeight(.semibold)
                .foregroundStyle(AppTheme.textPrimary)
            Text("Add a vehicle to see your health score")
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    func onAppear() {
        vehiclesVm.fetchVehicles()
        weather.requestLocationAndFetch()
    }

    func selectVehicle(_ vehicle: Vehicle) {
        selectedVehicle = vehicle
        animatedScore = 0
        guard let id = vehicle.id else { return }
        fuelVm.fetchRecords(vehicleId: id)
        maintenanceVm.fetchRecords(vehicleId: id)
    }

    func recalculate() {
        let score = HealthScoreService.calculate(
            fuelRecords: fuelVm.records,
            maintenanceRecords: maintenanceVm.records
        )
        healthScore = score
        withAnimation(.easeInOut(duration: 1.2)) {
            animatedScore = Double(score.score)
        }
    }
}

struct WeatherBanner: View {
    let alert: String

    var body: some View {
        if !alert.isEmpty {
            HStack(spacing: 12) {
                Text(alert)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
            }
            .padding()
            .background(AppTheme.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.accent.opacity(0.3), lineWidth: 1))
            .padding(.horizontal)
        }
    }
}

struct VehicleDashboardContent: View {
    let vehicle: Vehicle
    let healthScore: HealthScore?
    let animatedScore: Double
    let fuelCount: Int
    let maintenanceCount: Int
    let totalFuelSpent: Double

    var body: some View {
        VStack(spacing: 20) {
            vehicleCard
            HealthScoreRing(
                score: healthScore?.score ?? 0,
                label: healthScore?.label ?? "Calculating...",
                animatedScore: animatedScore
            )
            statsRow
            if let alerts = healthScore?.alerts, !alerts.isEmpty {
                AlertsSection(alerts: alerts)
            }
        }
        .padding(.bottom, 32)
    }

    var vehicleCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Vehicle image
            Image(vehicleImageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    // Gradient overlay at bottom
                    LinearGradient(
                        colors: [.clear, AppTheme.backgroundCard],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                )

            // Vehicle info
            VStack(alignment: .leading, spacing: 12) {
                Text(vehicle.nickname.isEmpty ? "\(String(vehicle.year)) \(vehicle.make) \(vehicle.model)" : vehicle.nickname)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.accent)

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Make")).font(.caption).foregroundStyle(AppTheme.textSecondary)
                        Text(vehicle.make).font(.subheadline).fontWeight(.semibold).foregroundStyle(AppTheme.textPrimary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Year")).font(.caption).foregroundStyle(AppTheme.textSecondary)
                        Text(String(vehicle.year)).font(.subheadline).fontWeight(.semibold).foregroundStyle(AppTheme.textPrimary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Mileage")).font(.caption).foregroundStyle(AppTheme.textSecondary)
                        Text("\(vehicle.mileage) km").font(.subheadline).fontWeight(.semibold).foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [AppTheme.cardBorderStart, AppTheme.cardBorderEnd],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .padding(.horizontal)
    }

    var vehicleImageName: String {
        switch vehicle.vehicleType.lowercased() {
        case "truck", "pickup truck": return "vehicle_truck"
        case "suv", "mpv": return "vehicle_suv"
        case "van", "minivan": return "vehicle_van"
        case "hatchback", "hatch": return "vehicle_hatch"
        default: return "vehicle_sedan"
        }
    }
    var statsRow: some View {
        HStack(spacing: 12) {
            DarkStatCard(title: String(localized: "Fuel Records"), value: "\(fuelCount)", icon: "fuelpump.fill", color: AppTheme.warning)
            DarkStatCard(title: String(localized: "Services"), value: "\(maintenanceCount)", icon: "wrench.fill", color: AppTheme.accent)
            DarkStatCard(title: String(localized: "Fuel Spent"), value: String(format: "$%.0f", totalFuelSpent), icon: "dollarsign.circle.fill", color: AppTheme.success)
        }
        .padding(.horizontal)
    }
}

struct DarkStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.textPrimary)
            Text(title)
                .font(.caption2)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 0.5))
    }
}

struct HealthScoreRing: View {
    let score: Int
    let label: String
    let animatedScore: Double

    var ringColor: Color {
        switch score {
        case 80...100: return AppTheme.success
        case 60..<80: return AppTheme.accent
        case 40..<60: return AppTheme.warning
        default: return AppTheme.danger
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(ringColor.opacity(0.15), lineWidth: 20)
                    .frame(width: 180, height: 180)
                Circle()
                    .trim(from: 0, to: animatedScore / 100)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(ringColor)
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding()
            Text("Vehicle Health Score")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.textMuted, lineWidth: 0.5))
        .padding(.horizontal)
    }
}

struct AlertsSection: View {
    let alerts: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Alerts")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal)
            ForEach(alerts, id: \.self) { alert in
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(AppTheme.warning)
                    Text(alert)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.warning.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.warning.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
            }
        }
    }
}
