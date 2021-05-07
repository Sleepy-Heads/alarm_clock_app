//
//  EditAlarmViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/28/21.
//

import UIKit

class EditAlarmViewController: UIViewController {
    
    @IBOutlet weak var alarmNametxt: UITextField!
    
    @IBOutlet weak var timetxt: UITextField!
    
    @IBOutlet weak var amPmControl: UISegmentedControl!
    
    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var monButton: UIButton!
    @IBOutlet weak var tueButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var thurButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var satButton: UIButton!
    
    var alarmsEditScreen : [Alarm] = []
    
    var daySun = false
    var dayMon = false
    var dayTue = false
    var dayWed = false
    var dayThur = false
    var dayFri = false
    var daySat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //repeatDays = MultiSelectSegmentedControl()
        //repeatDays.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func onDone(_ sender: Any) {
        let name = alarmNametxt.text!
        let time = timetxt.text!
        let sun = amPmControl.selectedSegmentIndex
        let week = [daySun, dayMon, dayTue, dayWed, dayThur, dayFri, daySat]
        let toggle = true
        
        let alarm = Alarm(alarmName: name, alarmTime: time, alarmPeriod: sun, alarmDays: week, alarmToggle: toggle)
        alarmsEditScreen.append(alarm)
        
        //dismiss(animated: true, completion: nil) // this should just cancel edit alarm, and go back to home screen
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil) // this should just cancel edit alarm, and go back to home screen
    }
    
    @IBAction func sunSwitch(_ sender: Any) {
        if (daySun) {
            daySun = false
            self.sunButton.backgroundColor = UIColor.white
        } else {
            daySun = true
            self.sunButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func monSwitch(_ sender: Any) {
        if (dayMon) {
            dayMon = false
            self.monButton.backgroundColor = UIColor.white
        } else {
            dayMon = true
            self.monButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func tueSwitch(_ sender: Any) {
        if (dayTue) {
            dayTue = false
            self.tueButton.backgroundColor = UIColor.white
        } else {
            dayTue = true
            self.tueButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func wedSwitch(_ sender: Any) {
        if (dayWed) {
            dayWed = false
            self.wedButton.backgroundColor = UIColor.white
        } else {
            dayWed = true
            self.wedButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func thurSwitch(_ sender: Any) {
        if (dayThur) {
            dayThur = false
            self.thurButton.backgroundColor = UIColor.white
        } else {
            dayThur = true
            self.thurButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func friSwitch(_ sender: Any) {
        if (dayFri) {
            dayFri = false
            self.friButton.backgroundColor = UIColor.white
        } else {
            dayFri = true
            self.friButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func satSwitch(_ sender: Any) {
        if (daySat) {
            daySat = false
            self.satButton.backgroundColor = UIColor.white
        } else {
            daySat = true
            self.satButton.backgroundColor = UIColor.lightGray
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let ViewController = segue.destination as? ViewController
        ViewController?.alarmsHomeScreen = alarmsEditScreen
    }

}
