import SwiftUI

struct AddFuelRecordView: View {
    @ObservedObject var vm: FuelViewModel
    let vehicle: Vehicle
    @Environment(\.dismiss) var dismiss

    @State private var date = Date()
    @State private var liters = ""
    @State private var costPerLiter = ""
    @State private var odometer = ""
    @State private var notes = ""
    @State private var isSaving = false

    var totalCost: Double {
        (Double(liters) ?? 0) * (Double(costPerLiter) ?? 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fill-up Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    HStack {
                        TextField("Liters", text: $liters)
                            .keyboardType(.decimalPad)
                        Text("L")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        TextField("Price per liter", text: $costPerLiter)
                            .keyboardType(.decimalPad)
                        Text("$/L")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Total Cost")
                        Spacer()
                        Text(String(format: "$%.2f", totalCost))
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                }

                Section("Optional") {
                    HStack {
                        TextField("Odometer", text: $odometer)
                            .keyboardType(.numberPad)
                        Text("km")
                            .foregroundStyle(.secondary)
                    }
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Log Fill-up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: save) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save").fontWeight(.semibold)
                        }
                    }
                    .disabled(liters.isEmpty || costPerLiter.isEmpty)
                }
            }
        }
    }

    func save() {
        guard let vehicleId = vehicle.id else { return }
        isSaving = true

        let record = FuelRecord(
            vehicleId: vehicleId,
            date: date,
            liters: Double(liters) ?? 0,
            costPerLiter: Double(costPerLiter) ?? 0,
            totalCost: totalCost,
            odometer: Int(odometer) ?? 0,
            notes: notes
        )

        vm.addRecord(record, vehicleId: vehicleId) { success in
            isSaving = false
            if success { dismiss() }
        }
    }
}
