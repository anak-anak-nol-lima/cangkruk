//
//  NotificationViewModelTests.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 15/07/26.
//

import Testing

@testable import Cangkruk

@MainActor
class NotificationViewModelTests {
    @Test("requesting permission to ensure it run", arguments: [
        (true),
        (false)
    ])
    func requestingPermission(permission: Bool) async {
        let fakeNotificationService = FakeLocalNotification()
        fakeNotificationService.permission = permission
        
        let vm = NotificationViewModel(notificationService: fakeNotificationService)
        let res = await vm.requestNotificationPermission()
        
        #expect(res == permission)
        #expect(fakeNotificationService.requestPermissionCalled == 1)
    }
    
    
    @Test("ensuring makeRequest return proper struct")
    func makeRequstReturnProperStruct() {
        let notificationService = LocalNotificationService()
        let vm = NotificationViewModel(notificationService: notificationService)
        
        
        let res = vm.notificationService.makeRequest(message: "Hello world", sentAt: 10)
        
        #expect(res.name == "Cangkruk")
        #expect(res.message == "Hello world")
        #expect(res.sentAt == 10)
    }
    
    @Test("ensuring makeDailySchedule properly return correct list of schedules")
    func makeDailySchedule() {
        let notificationService = LocalNotificationService()
        let vm = NotificationViewModel(notificationService: notificationService)
        
        let res = vm.notificationService.makeDailySchedule()
        
        #expect(res.count == 3)
    }
    
    
    @Test("ensuring the send notification getting called dailySchedule number of time")
    func scheduleDailyNotifications() async {
        let fakeNotificationService = FakeLocalNotification()
        let vm = NotificationViewModel(notificationService: fakeNotificationService)
        
        await vm.onAppBackgrounded()
        
        #expect(fakeNotificationService.sendNotificationCalled == 3)
    }
}
