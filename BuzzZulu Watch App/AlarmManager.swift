import Foundation
import Combine
import UserNotifications

class AlarmManager: ObservableObject {
    @Published var alarms: [ZuluAlarm] = []

    private let storageKey = "buzzzulu_alarms"

    init() {
        loadAlarms()
        requestNotificationPermission()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func addAlarm(hour: Int, minute: Int) {
        let alarm = ZuluAlarm(id: UUID(), hour: hour, minute: minute, enabled: true)
        alarms.append(alarm)
        scheduleNotification(for: alarm)
        saveAlarms()
    }

    func removeAlarm(_ alarm: ZuluAlarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }

    func toggleAlarm(_ alarm: ZuluAlarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index].enabled.toggle()

        if alarms[index].enabled {
            scheduleNotification(for: alarms[index])
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
        }
        saveAlarms()
    }

    func updateAlarm(_ alarm: ZuluAlarm, hour: Int, minute: Int, enabled: Bool) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }

        // Remove old notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])

        // Update alarm
        alarms[index].hour = hour
        alarms[index].minute = minute
        alarms[index].enabled = enabled

        // Schedule new notification if enabled
        if enabled {
            scheduleNotification(for: alarms[index])
        }
        saveAlarms()
    }

    private func scheduleNotification(for alarm: ZuluAlarm) {
        let content = UNMutableNotificationContent()
        content.title = "BuzzZulu"
        content.body = String(format: "%02d:%02dZ", alarm.hour, alarm.minute)
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(identifier: "UTC")
        dateComponents.hour = alarm.hour
        dateComponents.minute = alarm.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ZuluAlarm].self, from: data) {
            alarms = decoded
            // Re-schedule all enabled alarms
            for alarm in alarms where alarm.enabled {
                scheduleNotification(for: alarm)
            }
        }
    }
}

struct ZuluAlarm: Identifiable, Codable {
    let id: UUID
    var hour: Int
    var minute: Int
    var enabled: Bool

    var displayTime: String {
        String(format: "%02d:%02dZ", hour, minute)
    }
}
