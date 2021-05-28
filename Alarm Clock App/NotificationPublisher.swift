//
//  NotificationPublisher.swift
//  Alarm Clock App
//
//  Created by Paul Sayad on 5/14/21.
//

import Foundation
import UIKit // this is for the badge
import UserNotifications
import AVFoundation

class NotificationPublisher : NSObject, UNUserNotificationCenterDelegate {
    
    var player: AVAudioPlayer?
    
    func sendNotification(alarm : Alarm, badge: Int?) {
            
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = alarm.alarmName
        notificationContent.subtitle = alarm.alarmTime + " " + alarm.alarmPeriod
        notificationContent.body = "Click here to open the app and click the solve button!"
        
        if let badge = badge {
            var currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += badge
            notificationContent.badge = NSNumber(integerLiteral: currentBadgeCount)
        }
        
        notificationContent.sound = UNNotificationSound.default
        
        UNUserNotificationCenter.current().delegate = self
        
        var hour = ""
        if(alarm.alarmTime.count == 4){
            hour = String(alarm.alarmTime.prefix(1))
        } else {
            hour = String(alarm.alarmTime.prefix(2))
        }
        
        let minute = String(alarm.alarmTime.suffix(2))
        
        var intHour = Int(hour)!

        if(alarm.alarmPeriod == "PM" && intHour != 12){
            intHour += 12
        } else if(alarm.alarmPeriod  == "AM" && intHour == 12) {
            intHour = 0
        }
        
        var dateComponents = DateComponents()
        if(alarm.alarmDays.filter{$0}.count == 0) {
            dateComponents.hour = intHour
            dateComponents.minute = Int(minute)!
            dateComponents.timeZone = .current
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) // Repeating Alarm
            let request = UNNotificationRequest(identifier: alarm.alarmKey, content: notificationContent, trigger: trigger) // replace trigger with delaytimetrigger and vice versa for exact time
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } else {
            dateComponents.hour = intHour
            dateComponents.minute = Int(minute)!
            dateComponents.timeZone = .current
           
            let days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
            for i in alarm.alarmDays.enumerated() {
                if(i.element){
                    dateComponents.weekday = i.offset + 1
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: alarm.alarmKey + days[i.offset], content: notificationContent, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification is about to be presented") // When application in foreground
        let viewController:ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.playAlarmSound()
        let date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var amorpm = "AM"
        if(hour >= 13 && hour != 24){
            hour -= 12
            amorpm = "PM"
        }
        let systemTime = "\(hour):\(minutes)\(amorpm)"
        viewController.getPuzzleAndDifficulty(systemTime: systemTime)
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifer = response.actionIdentifier
                
        switch identifer {
        
        case UNNotificationDismissActionIdentifier:
            //print("The notification was dismissed")
            completionHandler()
            
        case UNNotificationDefaultActionIdentifier:
            //print("The User opened the app from the notification")
            completionHandler()
            
        default:
            print("The default case was called")
        }
    }
}
