import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class VehiclesViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    func fetchVehicles() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        db.collection("users").document(uid).collection("vehicles")
            .order(by: "created_at", descending: true)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.vehicles = snapshot?.documents.compactMap {
                        try? $0.data(as: Vehicle.self)
                    } ?? []
                }
            }
    }

    func addVehicle(_ vehicle: Vehicle, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            try db.collection("users").document(uid).collection("vehicles")
                .addDocument(from: vehicle)
            completion(true)
        } catch {
            self.errorMessage = error.localizedDescription
            completion(false)
        }
    }

    func deleteVehicle(_ vehicle: Vehicle) {
        guard let uid = Auth.auth().currentUser?.uid,
              let vehicleId = vehicle.id else { return }

        db.collection("users").document(uid).collection("vehicles")
            .document(vehicleId).delete()
    }

    func updateVehicle(_ vehicle: Vehicle, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid,
              let vehicleId = vehicle.id else { return }

        do {
            try db.collection("users").document(uid).collection("vehicles")
                .document(vehicleId).setData(from: vehicle)
            completion(true)
        } catch {
            self.errorMessage = error.localizedDescription
            completion(false)
        }
    }
}
