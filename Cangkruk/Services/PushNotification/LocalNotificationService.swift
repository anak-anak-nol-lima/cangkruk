//
//  LocalNotificationService.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 10/07/26.
//

import Foundation
import UserNotifications

class LocalNotificationService {
    static let shared = LocalNotificationService()
    
    private init() {}
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    func scheduleDailyNotifications() {
        let center = UNUserNotificationCenter.current()
        
        let messages = [
            "Kamu belum menyelesaikan modul hari ini🤯 Yuk, luangkan waktu sebentar buat kejar materinya sebelum makin menumpuk!☕️",
            "Progres belajarmu terhenti nih😓 Jangan sampai lupa teknik dasarnya, buka aplikasi dan selesaikan latihanmu sekarang!💪🏻",
            "Kamu sudah 3 hari berturut-turut bolos latihan😢 Buka aplikasi sekarang sebelum akun pelatihanmu otomatis ditandai untuk peninjauan internal lebih lanjut!👀"
        ]
        
        // looping agar notifnya berurutan per hari (tidak random/shuffle)
        for (index, message) in messages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Cangkruk"
            content.body = message
            content.sound = .default
            
            // untuk atur waktu muncul push notif (1 hari = 86.400 detik)
            let timeInterval = TimeInterval(86400 * (index + 1))
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            // ID untuk per notifnya (karena scheduled jd ID harus beda)
            let identifier = "daily_reminder_day_\(index + 1)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule notification for day \(index + 1): \(error.localizedDescription)")
                } else {
                    print("Notification for day \(index + 1) has been scheduled!")
                }
            }
        }
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All scheduled notifications have been canceled.")
    }
}
