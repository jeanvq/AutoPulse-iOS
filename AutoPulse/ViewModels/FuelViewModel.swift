import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class FuelViewModel: ObservableObject {
    @Published var records: [FuelRecord] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    func fetchRecords(vehicleId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        db.collection("users").document(uid)
            .collection("vehicles").document(vehicleId)
            .collection("fuel_records")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.records = snapshot?.documents.compactMap {
                        try? $0.data(as: FuelRecord.self)
                    } ?? []
                }
            }
    }

    func addRecord(_ record: FuelRecord, vehicleId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            try db.collection("users").document(uid)
                .collection("vehicles").document(vehicleId)
                .collection("fuel_records")
                .addDocument(from: record)
            completion(true)
        } catch {
            self.errorMessage = error.localizedDescription
            completion(false)
        }
    }

    func deleteRecord(_ record: FuelRecord, vehicleId: String) {
        guard let uid = Auth.auth().currentUser?.uid,
              let recordId = record.id else { return }

        db.collection("users").document(uid)
            .collection("vehicles").document(vehicleId)
            .collection("fuel_records")
            .document(recordId).delete()
    }

    var totalSpent: Double {
        records.reduce(0) { $0 + $1.totalCost }
    }

    var totalLiters: Double {
        records.reduce(0) { $0 + $1.liters }
    }

    var averageCostPerLiter: Double {
        guard !records.isEmpty else { return 0 }
        return totalSpent / totalLiters
    }
}
