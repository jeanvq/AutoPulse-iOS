import SwiftUI

struct MaintenanceView: View {
    @StateObject private var vm = MaintenanceViewModel()
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
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(AppTheme.accent)
                                }
                                Text("No vehicles yet")
                                    .font(.title3).fontWeight(.semibold)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Add a vehicle first to track maintenance")
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
                                                    .background(selectedVehicle?.id == vehicle.id ? AppTheme.warning : AppTheme.backgroundCard)
                                                    .foregroundStyle(selectedVehicle?.id == vehicle.id ? .white : AppTheme.textSecondary)
                                                    .clipShape(Capsule())
                                                    .overlay(Capsule().stroke(selectedVehicle?.id == vehicle.id ? AppTheme.warning : AppTheme.textMuted, lineWidth: 1))
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
                                            Image(systemName: "wrench.and.screwdriver")
                                                .font(.system(size: 50))
                                                .foregroundStyle(AppTheme.warning.opacity(0.4))
                                            Text("No maintenance records yet")
                                                .font(.title3).fontWeight(.semibold)
                                                .foregroundStyle(AppTheme.textPrimary)
                                            Text("Tap + to log your first service")
                                                .foregroundStyle(AppTheme.textSecondary)
                                            Spacer()
                                        }
                                    } else {
                                        ScrollView {
                                            VStack(spacing: 16) {
                                                // Stats
                                                HStack(spacing: 12) {
                                                    DarkStatCard(title: "Total Spent", value: String(format: "$%.2f", vm.totalSpent), icon: "dollarsign.circle.fill", color: AppTheme.success)
                                                    DarkStatCard(title: "Services", value: "\(vm.records.count)", icon: "wrench.fill", color: AppTheme.warning)
                                                    if let last = vm.lastService {
                                                        DarkStatCard(title: "Last Service", value: last.date.formatted(.dateTime.month().day()), icon: "calendar", color: AppTheme.accent)
                                                    }
                                                }
                                                .padding(.horizontal)

                                                // Records list
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Service History")
                                                        .font(.headline)
                                                        .foregroundStyle(AppTheme.textPrimary)
                                                        .padding(.horizontal)

                                                    ForEach(vm.records) { record in
                                                        MaintenanceRecordRow(record: record)
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
                .navigationTitle("Maintenance")
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
                        AddMaintenanceRecordView(vm: vm, vehicle: vehicle)
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

struct MaintenanceRecordRow: View {
    let record: MaintenanceRecord

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.warning.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: serviceIcon)
                    .foregroundStyle(AppTheme.warning)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(record.serviceType)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                if !record.shop.isEmpty {
                    Text(record.shop)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", record.cost))
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(AppTheme.success)
                Text("\(record.mileage) km")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 0.5))
    }

    var serviceIcon: String {
        let type = record.serviceType.lowercased()
        if type.contains("oil") { return "drop.fill" }
        if type.contains("tire") || type.contains("tyre") { return "circle.circle.fill" }
        if type.contains("brake") { return "exclamationmark.triangle.fill" }
        if type.contains("battery") { return "battery.100" }
        if type.contains("wash") { return "sparkles" }
        return "wrench.fill"
    }
}
