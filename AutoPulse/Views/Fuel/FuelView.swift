import SwiftUI
import Charts

struct FuelView: View {
    @StateObject private var vm = FuelViewModel()
    @StateObject private var vehiclesVm = VehiclesViewModel()
    @State private var selectedVehicle: Vehicle?
    @State private var showAddRecord = false

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            NavigationStack {
                ZStack {
                    AppTheme.backgroundPrimary.ignoresSafeArea()
                    Group {
                        if vehiclesVm.vehicles.isEmpty {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accentGlow)
                                        .frame(width: 80, height: 80)
                                    Image(systemName: "fuelpump.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(AppTheme.accent)
                                }
                                Text("No vehicles yet")
                                    .font(.title3).fontWeight(.semibold)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Add a vehicle first to track fuel records")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else {
                            VStack(spacing: 0) {
                                // Vehicle picker
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(vehiclesVm.vehicles) { vehicle in
                                            Button(action: {
                                                selectedVehicle = vehicle
                                                if let id = vehicle.id {
                                                    vm.fetchRecords(vehicleId: id)
                                                }
                                            }) {
                                                Text(vehicle.nickname.isEmpty ? "\(vehicle.make) \(vehicle.model)" : vehicle.nickname)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(selectedVehicle?.id == vehicle.id ? AppTheme.accent : AppTheme.backgroundCard)
                                                    .foregroundStyle(selectedVehicle?.id == vehicle.id ? .white : AppTheme.textSecondary)
                                                    .clipShape(Capsule())
                                                    .overlay(Capsule().stroke(selectedVehicle?.id == vehicle.id ? AppTheme.accent : AppTheme.textMuted, lineWidth: 1))
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                }

                                if let _ = selectedVehicle {
                                    if vm.records.isEmpty {
                                        VStack(spacing: 12) {
                                            Spacer()
                                            Image(systemName: "fuelpump")
                                                .font(.system(size: 50))
                                                .foregroundStyle(AppTheme.warning.opacity(0.4))
                                            Text("No fuel records yet")
                                                .font(.title3).fontWeight(.semibold)
                                                .foregroundStyle(AppTheme.textPrimary)
                                            Text("Tap + to log your first fill-up")
                                                .foregroundStyle(AppTheme.textSecondary)
                                            Spacer()
                                        }
                                    } else {
                                        ScrollView {
                                            VStack(spacing: 16) {
                                                // Stats
                                                HStack(spacing: 12) {
                                                    DarkStatCard(title: "Total Spent", value: String(format: "$%.2f", vm.totalSpent), icon: "dollarsign.circle.fill", color: AppTheme.success)
                                                    DarkStatCard(title: "Total Liters", value: String(format: "%.1fL", vm.totalLiters), icon: "fuelpump.fill", color: AppTheme.warning)
                                                    DarkStatCard(title: "Avg $/L", value: String(format: "$%.2f", vm.averageCostPerLiter), icon: "chart.line.uptrend.xyaxis", color: AppTheme.accent)
                                                }
                                                .padding(.horizontal)

                                                // Chart
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Monthly Spend")
                                                        .font(.headline)
                                                        .foregroundStyle(AppTheme.textPrimary)
                                                        .padding(.horizontal)

                                                    Chart(vm.records.prefix(10)) { record in
                                                        BarMark(
                                                            x: .value("Date", record.date, unit: .month),
                                                            y: .value("Cost", record.totalCost)
                                                        )
                                                        .foregroundStyle(AppTheme.accent.gradient)
                                                    }
                                                    .frame(height: 180)
                                                    .padding(.horizontal)
                                                    .chartXAxis {
                                                        AxisMarks(values: .stride(by: .month)) { _ in
                                                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                                                                .foregroundStyle(AppTheme.textSecondary)
                                                            AxisGridLine().foregroundStyle(AppTheme.textMuted)
                                                        }
                                                    }
                                                    .chartYAxis {
                                                        AxisMarks { _ in
                                                            AxisValueLabel()
                                                                .foregroundStyle(AppTheme.textSecondary)
                                                            AxisGridLine().foregroundStyle(AppTheme.textMuted)
                                                        }
                                                    }
                                                }
                                                .padding(.vertical, 12)
                                                .background(AppTheme.backgroundCard)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 0.5))
                                                .padding(.horizontal)

                                                // Records list
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("History")
                                                        .font(.headline)
                                                        .foregroundStyle(AppTheme.textPrimary)
                                                        .padding(.horizontal)

                                                    ForEach(vm.records) { record in
                                                        FuelRecordRow(record: record)
                                                            .padding(.horizontal)
                                                    }
                                                }
                                            }
                                            .padding(.vertical)
                                        }
                                    }
                                } else {
                                    Spacer()
                                    Text("Select a vehicle above")
                                        .foregroundStyle(AppTheme.textSecondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Fuel")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showAddRecord = true }) {
                            Image(systemName: "plus")
                                .foregroundStyle(AppTheme.accent)
                        }
                        .disabled(selectedVehicle == nil)
                    }
                }
                .sheet(isPresented: $showAddRecord) {
                    if let vehicle = selectedVehicle {
                        AddFuelRecordView(vm: vm, vehicle: vehicle)
                    }
                }
                .onAppear {
                    vehiclesVm.fetchVehicles()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if self.selectedVehicle == nil, let first = self.vehiclesVm.vehicles.first {
                            self.selectedVehicle = first
                            if let id = first.id {
                                vm.fetchRecords(vehicleId: id)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
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
        .padding(.vertical, 12)
        .background(AppTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 0.5))
    }
}

struct FuelRecordRow: View {
    let record: FuelRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(String(format: "%.1f L · $%.3f/L", record.liters, record.costPerLiter))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Text(String(format: "$%.2f", record.totalCost))
                .font(.headline)
                .foregroundStyle(AppTheme.success)
        }
        .padding()
        .background(AppTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.textMuted, lineWidth: 0.5))
    }
}
