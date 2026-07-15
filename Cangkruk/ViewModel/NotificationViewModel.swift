//
//  NotificationViewModel.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 10/07/26.
//

import SwiftUI

@Observable
class NotificationViewModel {
    var notificationService: LocalNotificationServiceProtocol
    
    init(notificationService: LocalNotificationServiceProtocol = LocalNotificationService()) {
        self.notificationService = notificationService
        
        Task {
            await requestNotificationPermission()
        }
    }
    
    func requestNotificationPermission() async -> Bool {
        let permission = await notificationService.requestPermission()
        return permission
    }
    
    func sendNotification(notification: ScheduleNotificationInfo) async {
        do {
            try await notificationService.sendNotification(notification: notification)
        } catch {
            print("sendNotification error: \(error) ")
        }
    }

    func onAppBackgrounded() async {
        await notificationService.scheduleDailyNotifications()
    }
    
    func onAppForegrounded() {
        notificationService.cancelNotifications()
    }
}
