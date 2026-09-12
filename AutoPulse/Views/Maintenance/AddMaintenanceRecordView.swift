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
    @State private var setReminder = false
    @State private var nextServiceDate = Date().addingTimeInterval(60 * 60 * 24 * 90) // 90 days from now
    
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
                
                Section("Next Service Reminder") {
                    Toggle("Set Reminder", isOn: $setReminder)
                        .tint(.orange)
                    
                    if setReminder {
                        DatePicker(
                            "Next Service Date",
                            selection: $nextServiceDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.orange)
                            Text("You'll get a notification on this date at 9:00 AM")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
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
            notes: notes,
            nextServiceDate: setReminder ? nextServiceDate : nil,
            reminderSet: setReminder
        )
        
        vm.addRecord(record, vehicleId: vehicleId) { success in
            if success {
                if self.setReminder, let recordId = record.id {
                    let vehicleName = self.vehicle.nickname.isEmpty ? "\(self.vehicle.make) \(self.vehicle.model)" : self.vehicle.nickname
                    
                    // Main reminder
                    NotificationService.shared.scheduleMaintenanceReminder(
                        vehicleName: vehicleName,
                        serviceType: self.serviceType,
                        date: self.nextServiceDate,
                        vehicleId: vehicleId,
                        serviceId: recordId
                    )
                    
                    // Follow-up reminder 7 days later
                    NotificationService.shared.scheduleFollowUpReminder(
                        vehicleName: vehicleName,
                        serviceType: self.serviceType,
                        originalDate: self.nextServiceDate,
                        vehicleId: vehicleId,
                        serviceId: recordId
                    )
                }
                self.isSaving = false
                HapticService.shared.success()
                self.dismiss()
            } else {
                HapticService.shared.error()
                self.isSaving = false
            }
        }
    }
}
