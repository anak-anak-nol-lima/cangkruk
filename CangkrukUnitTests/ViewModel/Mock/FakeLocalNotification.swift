//
//  FakeLocalNotification.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 15/07/26.
//

import Testing
import SwiftUI

@testable import Cangkruk


class FakeLocalNotification: LocalNotificationService {
    // MARK: - Stubs
    var permission: Bool = true
    
    // MARK: - Spy for checking the actual function getting hit or no
    var sendNotificationCalled: Int = 0
    var requestPermissionCalled: Int = 0
    
    
    override func requestPermission() async -> Bool {
        requestPermissionCalled += 1
        return permission
    }
    
    override func sendNotification(notification: ScheduleNotificationInfo) async throws {
        sendNotificationCalled += 1
    }
}
