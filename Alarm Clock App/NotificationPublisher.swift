//
//  NotificationPublisher.swift
//  Alarm Clock App
//
//  Created by Paul Sayad on 5/14/21.
//

import Foundation
import UIKit // this is for the badge
import UserNotifications

class NotificationPublisher : NSObject {
    
    func sendNotification(title: String, subtitle: String, body: String, badge: Int?, delayInterval: Int?) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body
        
        var delayTimeTrigger: UNTimeIntervalNotificationTrigger?
        
        if let delayInterval = delayInterval {
            delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval), repeats: false)
        }
        
        if let badge = badge {
            var currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += badge
            notificationContent.badge = NSNumber(integerLiteral: currentBadgeCount)
        }
        
        notificationContent.sound = UNNotificationSound.default
        
        UNUserNotificationCenter.current().delegate = self
        
        
        //var dateComponents = DateComponents()
        //dateComponents.hour = hour
        //dateComponents.minute = minute
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) // This will make an alarm at 10:30 every morning
        let request = UNNotificationRequest(identifier: "TestLocalNotification", content: notificationContent, trigger: delayTimeTrigger) // replace trigger with delaytimetrigger and vice versa for exact time
        
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

extension NotificationPublisher : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification is about to be presented")
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifer = response.actionIdentifier
        
        let instanceOfMain = ViewController()
        
        switch identifer {
        
        case UNNotificationDismissActionIdentifier:
            print("The notification was dismissed")
            completionHandler()
            
        case UNNotificationDefaultActionIdentifier:
            print("The User opened the app from the notification")
            instanceOfMain.solveAlarm()
            completionHandler()
            
        default:
            print("The default case was called")
        }
    }
}
