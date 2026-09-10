import Foundation
import FirebaseFirestore

struct FuelRecord: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var vehicleId: String
    var date: Date
    var liters: Double
    var costPerLiter: Double
    var totalCost: Double
    var odometer: Int
    var notes: String

    enum CodingKeys: String, CodingKey {
        case id
        case vehicleId = "vehicle_id"
        case date
        case liters
        case costPerLiter = "cost_per_liter"
        case totalCost = "total_cost"
        case odometer
        case notes
    }
}
