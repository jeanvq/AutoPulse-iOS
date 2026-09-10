import Foundation
import FirebaseFirestore

struct Vehicle: Identifiable, Codable, Equatable {    @DocumentID var id: String?
    var make: String
    var model: String
    var year: Int
    var vin: String
    var color: String
    var nickname: String
    var vehicleType: String
    var mileage: Int
    var userId: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case make
        case model
        case year
        case vin
        case color
        case nickname
        case vehicleType = "vehicle_type"
        case mileage
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
