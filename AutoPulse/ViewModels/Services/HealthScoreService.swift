import Foundation

struct HealthScore {
    let score: Int
    let label: String
    let color: String
    let alerts: [String]
}

class HealthScoreService {
    static func calculate(
        fuelRecords: [FuelRecord],
        maintenanceRecords: [MaintenanceRecord]
    ) -> HealthScore {
        var score = 100
        var alerts: [String] = []

        // Fuel check
        if fuelRecords.isEmpty {
            score -= 20
            alerts.append(String(localized: "No fuel records logged yet"))
        } else if let lastFuel = fuelRecords.first {
            let daysSinceLastFuel = Calendar.current.dateComponents([.day], from: lastFuel.date, to: Date()).day ?? 0
            if daysSinceLastFuel > 60 {
                score -= 20
                alerts.append(String(localized: "No fuel logged in over 60 days"))
            } else if daysSinceLastFuel > 30 {
                score -= 10
                alerts.append(String(localized: "No fuel logged in over 30 days"))
            }
        }

        // Maintenance check
        if maintenanceRecords.isEmpty {
            score -= 30
            alerts.append(String(localized: "No maintenance records logged yet"))
        } else if let lastMaintenance = maintenanceRecords.first {
            let daysSinceLastMaintenance = Calendar.current.dateComponents([.day], from: lastMaintenance.date, to: Date()).day ?? 0
            if daysSinceLastMaintenance > 180 {
                score -= 30
                alerts.append(String(localized: "No maintenance in over 6 months"))
            } else if daysSinceLastMaintenance > 90 {
                score -= 15
                alerts.append(String(localized: "No maintenance in over 90 days"))
            }
        }

        // Clamp score
        score = max(0, min(100, score))

        // Label and color
        let label: String
        let color: String

        switch score {
        case 80...100:
            label = String(localized: "Excellent")
            color = "green"
        case 60..<80:
            label = String(localized: "Good")
            color = "blue"
        case 40..<60:
            label = String(localized: "Fair")
            color = "orange"
        default:
            label = String(localized: "Poor")
            color = "red"
        }

        return HealthScore(score: score, label: label, color: color, alerts: alerts)
    }
}
