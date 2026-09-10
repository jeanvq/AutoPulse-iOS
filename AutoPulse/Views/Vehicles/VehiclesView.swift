import SwiftUI

struct VehiclesView: View {
    @StateObject private var vm = VehiclesViewModel()
    @EnvironmentObject var auth: AuthViewModel
    @State private var showAddVehicle = false

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            NavigationStack {
                ZStack {
                    AppTheme.backgroundPrimary.ignoresSafeArea()
                    Group {
                        if vm.isLoading {
                            ProgressView().tint(AppTheme.accent)
                        } else if vm.vehicles.isEmpty {
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
                                Text("Add your first vehicle to get started")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                Button(action: { showAddVehicle = true }) {
                                    Label("Add Vehicle", systemImage: "plus")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(AppTheme.accent)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal, 40)
                            }
                            .padding()
                        } else {
                            List {
                                ForEach(vm.vehicles) { vehicle in
                                    NavigationLink(destination: VehicleDetailView(vehicle: vehicle, vm: vm)) {
                                        VehicleRowView(vehicle: vehicle)
                                    }
                                    .listRowBackground(AppTheme.backgroundCard)
                                }
                                .onDelete { indexSet in
                                    indexSet.forEach { vm.deleteVehicle(vm.vehicles[$0]) }
                                }
                            }
                            .listStyle(.insetGrouped)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                .navigationTitle("My Vehicles")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showAddVehicle = true }) {
                            Image(systemName: "plus")
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                }
                .sheet(isPresented: $showAddVehicle) {
                    AddVehicleView(vm: vm)
                }
                .onAppear { vm.fetchVehicles() }
            }
        }
    }
}
