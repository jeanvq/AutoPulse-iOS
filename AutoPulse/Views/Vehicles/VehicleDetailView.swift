import SwiftUI

struct VehicleDetailView: View {
    let vehicle: Vehicle
    let vm: VehiclesViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.blue)
                        Text(vehicle.nickname.isEmpty ? "\(vehicle.year) \(vehicle.make) \(vehicle.model)" : vehicle.nickname)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(vehicle.make) \(vehicle.model)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            Section("Details") {
                LabeledContent("Year", value: "\(vehicle.year)")
                LabeledContent("Make", value: vehicle.make)
                LabeledContent("Model", value: vehicle.model)
                LabeledContent("Color", value: vehicle.color.isEmpty ? "—" : vehicle.color)
                LabeledContent("Type", value: vehicle.vehicleType)
                LabeledContent("Mileage", value: "\(vehicle.mileage) km")
                if !vehicle.vin.isEmpty {
                    LabeledContent("VIN", value: vehicle.vin)
                }
            }

            Section {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete Vehicle", systemImage: "trash")
                }
            }
        }
        .navigationTitle(vehicle.nickname.isEmpty ? "\(vehicle.make) \(vehicle.model)" : vehicle.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEdit = true }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditVehicleView(vm: vm, vehicle: vehicle)
        }
        .alert("Delete Vehicle?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                vm.deleteVehicle(vehicle)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
