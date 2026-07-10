//
//  NotificationViewModel.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 10/07/26.
//

import SwiftUI

@Observable
class NotificationViewModel {
    var isGameActive = true
    
    init() {
        LocalNotificationService.shared.requestPermission()
    }
    
    func onAppBackgrounded() {
        LocalNotificationService.shared.scheduleDailyNotifications()
    }
    
    func onAppForegrounded() {
        LocalNotificationService.shared.cancelNotifications()
    }
}
