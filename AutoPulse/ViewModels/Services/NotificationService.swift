import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notifications permission granted")
            }
        }
    }

    func scheduleMaintenanceReminder(vehicleName: String, serviceType: String, date: Date, vehicleId: String, serviceId: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔧 Maintenance Reminder"
        content.body = "\(vehicleName) — \(serviceType) is scheduled for today!"
        content.sound = .default
        content.badge = 1

        // Trigger on the scheduled date at 9 AM
        var calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "maintenance-\(vehicleId)-\(serviceId)"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func cancelReminder(vehicleId: String, serviceId: String) {
        let identifier = "maintenance-\(vehicleId)-\(serviceId)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func getPendingReminders(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.filter { $0.identifier.hasPrefix("maintenance-") })
            }
        }
    }
    func scheduleFollowUpReminder(vehicleName: String, serviceType: String, originalDate: Date, vehicleId: String, serviceId: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔧 Service Still Pending?"
        content.body = "\(vehicleName) — Did you get your \(serviceType) done? Log it in AutoPulse!"
        content.sound = .default
        content.badge = 1

        // Send follow-up 7 days after the scheduled date
        let followUpDate = originalDate.addingTimeInterval(60 * 60 * 24 * 7)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: followUpDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "followup-\(vehicleId)-\(serviceId)"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling follow-up: \(error)")
            }
        }
    }
}
