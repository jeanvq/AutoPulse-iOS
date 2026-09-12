import Foundation
import FirebaseFirestore

struct MaintenanceRecord: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var vehicleId: String
    var date: Date
    var serviceType: String
    var mileage: Int
    var cost: Double
    var shop: String
    var notes: String
    var nextServiceDate: Date?
    var reminderSet: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case vehicleId = "vehicle_id"
        case date
        case serviceType = "service_type"
        case mileage
        case cost
        case shop
        case notes
        case nextServiceDate = "next_service_date"
        case reminderSet = "reminder_set"
    }
}
