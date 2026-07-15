//
//  LocalNotificationService.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 10/07/26.
//

import Foundation
import UserNotifications


protocol LocalNotificationServiceProtocol {
    func requestPermission() async -> Bool
    func scheduleDailyNotifications() async
    func sendNotification(notification: ScheduleNotificationInfo) async throws
    func cancelNotifications()
    func makeRequest(message: String, sentAt: TimeInterval) -> ScheduleNotificationInfo
    func makeDailySchedule() -> [ScheduleNotificationInfo]
}


struct ScheduleNotificationInfo: Identifiable {
    var id = UUID()
    var name: String
    var message: String
    var sentAt: TimeInterval
}

class LocalNotificationService: LocalNotificationServiceProtocol {
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
                continuation.resume(returning: granted)
            }
        }
    }
    
    func makeRequest(message: String, sentAt: TimeInterval) -> ScheduleNotificationInfo {
        return ScheduleNotificationInfo(
            name: "Cangkruk",
            message: message,
            sentAt: sentAt
        )
    }
    
    func makeDailySchedule() -> [ScheduleNotificationInfo] {
        let messages = [
            "Kamu belum menyelesaikan modul hari ini🤯 Yuk, luangkan waktu sebentar buat kejar materinya sebelum makin menumpuk!☕️",
            "Progres belajarmu terhenti nih😓 Jangan sampai lupa teknik dasarnya, buka aplikasi dan selesaikan latihanmu sekarang!💪🏻",
            "Kamu sudah 3 hari berturut-turut bolos latihan😢 Buka aplikasi sekarang sebelum akun pelatihanmu otomatis ditandai untuk peninjauan internal lebih lanjut!👀"
        ]
        var schedules: [ScheduleNotificationInfo] = []
        for (idx, message) in messages.enumerated() {
            schedules.append(
                makeRequest(
                    message: message,
                    sentAt: TimeInterval(86400 * (idx + 1))
                )
            )
        }
        return schedules
    }
    
    
    // scheduleDailyNotifications will scheduling the notification to run multiple times
    // will call several function to build request, to send request per day
    func scheduleDailyNotifications() async {
        print("All scheduled notifications have been setup.")
        
        let schedules = makeDailySchedule()
        for schedule in schedules {
            do {
                try await sendNotification(notification: schedule)
            } catch {
                print("scheduleDailyNotifications: error happend \(error)")
            }
        }
    }
    
    
    // sendNotification will sending the notification based on the payload request
    // will send at sentAt variable that trigger daily
    func sendNotification(notification: ScheduleNotificationInfo) async throws {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = notification.name
        content.body = notification.message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notification.sentAt, repeats: false)
        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All scheduled notifications have been canceled.")
    }
}
