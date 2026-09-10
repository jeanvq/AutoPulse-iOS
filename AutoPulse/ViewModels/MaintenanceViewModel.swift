import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class MaintenanceViewModel: ObservableObject {
    @Published var records: [MaintenanceRecord] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    func fetchRecords(vehicleId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        db.collection("users").document(uid)
            .collection("vehicles").document(vehicleId)
            .collection("maintenance_records")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.records = snapshot?.documents.compactMap {
                        try? $0.data(as: MaintenanceRecord.self)
                    } ?? []
                }
            }
    }

    func addRecord(_ record: MaintenanceRecord, vehicleId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            try db.collection("users").document(uid)
                .collection("vehicles").document(vehicleId)
                .collection("maintenance_records")
                .addDocument(from: record)
            completion(true)
        } catch {
            self.errorMessage = error.localizedDescription
            completion(false)
        }
    }

    func deleteRecord(_ record: MaintenanceRecord, vehicleId: String) {
        guard let uid = Auth.auth().currentUser?.uid,
              let recordId = record.id else { return }

        db.collection("users").document(uid)
            .collection("vehicles").document(vehicleId)
            .collection("maintenance_records")
            .document(recordId).delete()
    }

    var totalSpent: Double {
        records.reduce(0) { $0 + $1.cost }
    }

    var lastService: MaintenanceRecord? {
        records.first
    }
}
