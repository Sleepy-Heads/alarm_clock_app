//
//  Alarm.swift
//  Alarm Clock App
//
//  Created by Paul Sayad on 5/5/21.
//

import Foundation

struct Alarm {
    var alarmName : String
    var alarmTime : String
    var alarmPeriod : String
    var alarmDays : [Bool]
    var alarmToggle : Bool
    
    init(dictionary : NSDictionary) {
        alarmName = dictionary["name"] as! String
        alarmTime = dictionary["time"] as! String
        alarmPeriod = dictionary["period"] as! String
        alarmDays = dictionary["days"] as! [Bool]
        alarmToggle = dictionary["toggle"] as! Bool
    }
    
    init(alarmName: String, alarmTime: String, alarmPeriod: String, alarmDays: [Bool], alarmToggle: Bool) {
        self.alarmName = alarmName
        self.alarmTime = alarmTime
        self.alarmPeriod = alarmPeriod
        self.alarmDays = alarmDays
        self.alarmToggle = alarmToggle
    }
}
