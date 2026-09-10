import SwiftUI

struct EditVehicleView: View {
    @ObservedObject var vm: VehiclesViewModel
    @Environment(\.dismiss) var dismiss

    let vehicle: Vehicle

    @State private var make: String
    @State private var model: String
    @State private var year: String
    @State private var color: String
    @State private var nickname: String
    @State private var mileage: String
    @State private var vehicleType: String
    @State private var isSaving = false

    let vehicleTypes = ["Car", "Truck", "SUV", "MPV", "Motorcycle"]

    init(vm: VehiclesViewModel, vehicle: Vehicle) {
        self.vm = vm
        self.vehicle = vehicle
        _make = State(initialValue: vehicle.make)
        _model = State(initialValue: vehicle.model)
        _year = State(initialValue: "\(vehicle.year)")
        _color = State(initialValue: vehicle.color)
        _nickname = State(initialValue: vehicle.nickname)
        _mileage = State(initialValue: "\(vehicle.mileage)")
        _vehicleType = State(initialValue: vehicle.vehicleType)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Info") {
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Year", text: $year)
                        .keyboardType(.numberPad)
                    Picker("Type", selection: $vehicleType) {
                        ForEach(vehicleTypes, id: \.self) { Text($0) }
                    }
                    TextField("Color", text: $color)
                }

                Section("Optional") {
                    TextField("Nickname", text: $nickname)
                    HStack {
                        TextField("Current Mileage", text: $mileage)
                            .keyboardType(.numberPad)
                        Text("km").foregroundStyle(.secondary)
                    }
                }

                if !vm.errorMessage.isEmpty {
                    Section {
                        Text(vm.errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Vehicle")
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
                    .disabled(make.isEmpty || model.isEmpty || year.isEmpty)
                }
            }
        }
    }

    func save() {
        guard let yearInt = Int(year) else { return }
        isSaving = true

        var updated = vehicle
        updated.make = make
        updated.model = model
        updated.year = yearInt
        updated.color = color
        updated.nickname = nickname
        updated.mileage = Int(mileage) ?? vehicle.mileage
        updated.vehicleType = vehicleType

        vm.updateVehicle(updated) { success in
            isSaving = false
            if success { dismiss() }
        }
    }
}
