//
//  Defaults.swift
//  Alarm Clock App
//
//  Created by Paul Sayad on 5/12/21.
//

import Foundation

struct Defaults {
    static var alarms = UserDefaults.standard.array(forKey: "alarms") ?? []
    
    static func addAlarm(alarm : Alarm) {
        let alarmDic = ["name" : alarm.alarmName, "time" : alarm.alarmTime, "period" : alarm.alarmPeriod, "days" : alarm.alarmDays, "toggle" : alarm.alarmToggle] as [String : Any]
        
        Defaults.alarms.append(alarmDic)
        UserDefaults.standard.setValue(Defaults.alarms, forKey: "alarms")
    }
    
    static func getAlarmObjects() -> [Alarm] {
        var alarmObjects : [Alarm] = []
        for alarmDictionary in Defaults.alarms {
            let alarm = Alarm.init(dictionary: alarmDictionary as! NSDictionary)
            alarmObjects.append(alarm)
        }
        
        return alarmObjects
    }
    
    static func updateAlarmObject(index : Int, alarm : Alarm) {
        Defaults.alarms[index] = ["name" : alarm.alarmName, "time" : alarm.alarmTime, "period" : alarm.alarmPeriod, "days" : alarm.alarmDays, "toggle" : alarm.alarmToggle] as [String : Any]
        UserDefaults.standard.setValue(Defaults.alarms, forKey: "alarms")
    }
    
    static func deleteAlarmObject(index : Int) {
        Defaults.alarms.remove(at: index)
        UserDefaults.standard.setValue(Defaults.alarms, forKey: "alarms")
    }
}
