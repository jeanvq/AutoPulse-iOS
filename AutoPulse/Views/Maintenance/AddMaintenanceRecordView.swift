import SwiftUI

struct AddMaintenanceRecordView: View {
    @ObservedObject var vm: MaintenanceViewModel
    let vehicle: Vehicle
    @Environment(\.dismiss) var dismiss

    @State private var date = Date()
    @State private var serviceType = ""
    @State private var mileage = ""
    @State private var cost = ""
    @State private var shop = ""
    @State private var notes = ""
    @State private var isSaving = false

    let commonServices = ["Oil Change", "Tire Rotation", "Brake Service",
                          "Battery Replacement", "Air Filter", "Car Wash", "Inspection"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Service Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    TextField("Service Type", text: $serviceType)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonServices, id: \.self) { service in
                                Button(action: { serviceType = service }) {
                                    Text(service)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(serviceType == service ? Color.orange : Color(.systemGray5))
                                        .foregroundStyle(serviceType == service ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Cost & Mileage") {
                    HStack {
                        TextField("Cost", text: $cost)
                            .keyboardType(.decimalPad)
                        Text("$")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        TextField("Mileage", text: $mileage)
                            .keyboardType(.numberPad)
                        Text("km")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Optional") {
                    TextField("Shop / Mechanic", text: $shop)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Log Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: save) {
                        if isSaving { ProgressView() }
                        else { Text("Save").fontWeight(.semibold) }
                    }
                    .disabled(serviceType.isEmpty)
                }
            }
        }
    }

    func save() {
        guard let vehicleId = vehicle.id else { return }
        isSaving = true

        let record = MaintenanceRecord(
            vehicleId: vehicleId,
            date: date,
            serviceType: serviceType,
            mileage: Int(mileage) ?? 0,
            cost: Double(cost) ?? 0,
            shop: shop,
            notes: notes
        )

        vm.addRecord(record, vehicleId: vehicleId) { success in
            isSaving = false
            if success { dismiss() }
        }
    }
}
