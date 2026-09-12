import SwiftUI

enum HealthFactorStatus {
    case good
    case warning
    case neutral

    var color: Color {
        switch self {
        case .good: return AppTheme.success
        case .warning: return AppTheme.danger
        case .neutral: return AppTheme.textMuted
        }
    }
}

struct HealthFactor: Identifiable {
    let id = UUID()
    let text: String
    let status: HealthFactorStatus
}

struct HealthScore {
    let score: Int
    let label: String
    let color: String
    let alerts: [String]
    let factors: [HealthFactor]
    let conditionTitle: String
    let conditionDescription: String
}

class HealthScoreService {
    static func calculate(
        fuelRecords: [FuelRecord],
        maintenanceRecords: [MaintenanceRecord]
    ) -> HealthScore {
        var score = 100
        var alerts: [String] = []
        var factors: [HealthFactor] = []

        // Fuel check
        if fuelRecords.isEmpty {
            score -= 20
            alerts.append(String(localized: "No fuel records logged yet"))
            factors.append(HealthFactor(text: String(localized: "No fuel records logged yet"), status: .warning))
        } else if let lastFuel = fuelRecords.first {
            let daysSinceLastFuel = Calendar.current.dateComponents([.day], from: lastFuel.date, to: Date()).day ?? 0
            if daysSinceLastFuel > 60 {
                score -= 20
                alerts.append(String(localized: "No fuel logged in over 60 days"))
                factors.append(HealthFactor(text: String(localized: "No fuel logged in over 60 days"), status: .warning))
            } else if daysSinceLastFuel > 30 {
                score -= 10
                alerts.append(String(localized: "No fuel logged in over 30 days"))
                factors.append(HealthFactor(text: String(localized: "No recent fuel records"), status: .neutral))
            } else {
                factors.append(HealthFactor(text: String(localized: "Recent fuel record logged"), status: .good))
            }
        }

        // Maintenance check
        if maintenanceRecords.isEmpty {
            score -= 30
            alerts.append(String(localized: "No maintenance records logged yet"))
            factors.append(HealthFactor(text: String(localized: "No maintenance records logged yet"), status: .warning))
        } else if let lastMaintenance = maintenanceRecords.first {
            let daysSinceLastMaintenance = Calendar.current.dateComponents([.day], from: lastMaintenance.date, to: Date()).day ?? 0
            if daysSinceLastMaintenance > 180 {
                score -= 30
                alerts.append(String(localized: "No maintenance in over 6 months"))
                factors.append(HealthFactor(text: String(localized: "No maintenance in over 6 months"), status: .warning))
            } else if daysSinceLastMaintenance > 90 {
                score -= 15
                alerts.append(String(localized: "No maintenance in over 90 days"))
                factors.append(HealthFactor(text: String(localized: "No maintenance in over 90 days"), status: .neutral))
            } else {
                factors.append(HealthFactor(text: String(localized: "Maintenance up to date"), status: .good))
            }
        }

        // Check overdue scheduled maintenance
        let now = Date()
        var overdueCount = 0
        for record in maintenanceRecords {
            if let nextDate = record.nextServiceDate, record.reminderSet {
                if nextDate < now {
                    let daysOverdue = Calendar.current.dateComponents([.day], from: nextDate, to: now).day ?? 0
                    score -= min(20, daysOverdue / 7 * 5)
                    alerts.append("⚠️ \(record.serviceType) is overdue by \(daysOverdue) days")
                    overdueCount += 1
                } else {
                    let daysUntil = Calendar.current.dateComponents([.day], from: now, to: nextDate).day ?? 0
                    if daysUntil <= 7 {
                        alerts.append("📅 \(record.serviceType) due in \(daysUntil) days")
                    }
                }
            }
        }

        if overdueCount > 0 {
            let text = overdueCount == 1
                ? String(localized: "1 overdue maintenance")
                : String(format: String(localized: "%d overdue maintenance"), overdueCount)
            factors.append(HealthFactor(text: text, status: .warning))
        } else {
            factors.append(HealthFactor(text: String(localized: "No overdue maintenance"), status: .good))
        }

        // Clamp score
        score = max(0, min(100, score))

        let label: String
        let color: String
        let conditionTitle: String
        let conditionDescription: String

        switch score {
        case 80...100:
            label = String(localized: "Excellent")
            color = "green"
            conditionTitle = String(localized: "Excellent Condition")
            conditionDescription = String(localized: "Your vehicle is in excellent condition!")
        case 60..<80:
            label = String(localized: "Good")
            color = "blue"
            conditionTitle = String(localized: "Good Condition")
            conditionDescription = String(localized: "Your vehicle is doing well but some attention is needed.")
        case 40..<60:
            label = String(localized: "Fair")
            color = "orange"
            conditionTitle = String(localized: "Fair Condition")
            conditionDescription = String(localized: "Your vehicle needs some attention soon.")
        default:
            label = String(localized: "Poor")
            color = "red"
            conditionTitle = String(localized: "Poor Condition")
            conditionDescription = String(localized: "Your vehicle needs immediate attention.")
        }

        return HealthScore(
            score: score,
            label: label,
            color: color,
            alerts: alerts,
            factors: factors,
            conditionTitle: conditionTitle,
            conditionDescription: conditionDescription
        )
    }
}
