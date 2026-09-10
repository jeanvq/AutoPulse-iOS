import SwiftUI

struct VehicleRowView: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 52, height: 52)
                Image(systemName: vehicleIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.nickname.isEmpty ? "\(vehicle.year) \(vehicle.make) \(vehicle.model)" : vehicle.nickname)
                    .font(.headline)
                Text("\(vehicle.year) · \(vehicle.make) \(vehicle.model)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(vehicle.mileage) km")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    var vehicleIcon: String {
        switch vehicle.vehicleType.lowercased() {
        case "truck": return "truck.box.fill"
        case "suv", "mpv": return "car.fill"
        case "motorcycle": return "figure.outdoor.cycle"
        default: return "car.fill"
        }
    }
}
