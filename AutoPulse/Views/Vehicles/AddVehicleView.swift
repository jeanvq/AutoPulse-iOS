import SwiftUI

struct AddVehicleView: View {
    @ObservedObject var vm: VehiclesViewModel
    @Environment(\.dismiss) var dismiss

    @State private var vin = ""
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var color = ""
    @State private var nickname = ""
    @State private var mileage = ""
    @State private var vehicleType = "Car"
    @State private var isLookingUp = false
    @State private var vinMessage = ""
    @State private var isSaving = false

    let vehicleTypes = ["Car", "Truck", "SUV", "MPV", "Motorcycle"]

    var body: some View {
        NavigationStack {
            Form {
                Section("VIN Lookup") {
                    HStack {
                        TextField("Enter VIN (optional)", text: $vin)
                            .textInputAutocapitalization(.characters)
                            .onChange(of: vin) { _, newValue in
                                vin = newValue.uppercased()
                            }
                        if isLookingUp {
                            ProgressView()
                        } else {
                            Button("Lookup") { lookupVIN() }
                                .disabled(vin.count < 17)
                        }
                    }
                    if !vinMessage.isEmpty {
                        Text(vinMessage)
                            .font(.caption)
                            .foregroundStyle(vinMessage.contains("✅") ? .green : .red)
                    }
                }

                Section("Vehicle Info") {
                    TextField("Make (e.g. Toyota)", text: $make)
                    TextField("Model (e.g. Camry)", text: $model)
                    TextField("Year (e.g. 2020)", text: $year)
                        .keyboardType(.numberPad)
                    Picker("Type", selection: $vehicleType) {
                        ForEach(vehicleTypes, id: \.self) { Text($0) }
                    }
                    TextField("Color", text: $color)
                }

                Section("Optional") {
                    TextField("Nickname (e.g. My Daily Driver)", text: $nickname)
                    TextField("Current Mileage (km)", text: $mileage)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveVehicle) {
                        if isSaving { ProgressView() }
                        else { Text("Save").fontWeight(.semibold) }
                    }
                    .disabled(make.isEmpty || model.isEmpty || year.isEmpty)
                }
            }
        }
    }

    func lookupVIN() {
        guard vin.count == 17 else { return }
        isLookingUp = true
        vinMessage = ""
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/\(vin)?format=json"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLookingUp = false
                guard let data = data, error == nil else { vinMessage = "❌ Lookup failed"; return }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["Results"] as? [[String: Any]] {
                    func value(for variable: String) -> String {
                        results.first(where: { $0["Variable"] as? String == variable })?["Value"] as? String ?? ""
                    }
                    let fetchedMake = value(for: "Make")
                    let fetchedModel = value(for: "Model")
                    let fetchedYear = value(for: "Model Year")
                    let fetchedType = value(for: "Vehicle Type")
                    if !fetchedMake.isEmpty {
                        make = fetchedMake.capitalized
                        model = fetchedModel.capitalized
                        year = fetchedYear
                        vehicleType = fetchedType.isEmpty ? "Car" : fetchedType.capitalized
                        vinMessage = "✅ Vehicle found!"
                    } else {
                        vinMessage = "❌ VIN not recognized"
                    }
                }
            }
        }.resume()
    }

    func saveVehicle() {
        guard let yearInt = Int(year) else { return }
        isSaving = true
        let vehicle = Vehicle(
            make: make, model: model, year: yearInt, vin: vin,
            color: color, nickname: nickname, vehicleType: vehicleType,
            mileage: Int(mileage) ?? 0, userId: "", createdAt: Date()
        )
        vm.addVehicle(vehicle) { success in
            isSaving = false
            if success { dismiss() }
        }
    }
}
