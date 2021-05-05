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
        print (name as Any)
        
        let time = timetxt.text!
        //print (atime as Any)
        
        let sun = amPmControl.selectedSegmentIndex
        if sun == 0 {
            print (time + " AM")
        } else {
            print(time + " PM")
        }

        var alarmWeek = [daySun, dayMon, dayTue, dayWed, dayThur, dayFri, daySat]
        
        print (alarmWeek)
        
        // currentGame = Game(word: newWord, incorrectMovesRemaining: incorrectMovesAllowed)
        
        let alarm = Alarm(alarmName: name, alarmTime: time)
        alarmsEditScreen.append(alarm)
        
        dismiss(animated: true, completion: nil)
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
        print(daySun)
    }
    @IBAction func monSwitch(_ sender: Any) {
        if (dayMon) {
            dayMon = false
            self.monButton.backgroundColor = UIColor.white
        } else {
            dayMon = true
            self.monButton.backgroundColor = UIColor.lightGray
        }
        print(dayMon)
    }
    @IBAction func tueSwitch(_ sender: Any) {
        if (dayTue) {
            dayTue = false
            self.tueButton.backgroundColor = UIColor.white
        } else {
            dayTue = true
            self.tueButton.backgroundColor = UIColor.lightGray
        }
        print(dayTue)
    }
    @IBAction func wedSwitch(_ sender: Any) {
        if (dayWed) {
            dayWed = false
            self.wedButton.backgroundColor = UIColor.white
        } else {
            dayWed = true
            self.wedButton.backgroundColor = UIColor.lightGray
        }
        print(dayWed)
    }
    @IBAction func thurSwitch(_ sender: Any) {
        if (dayThur) {
            dayThur = false
            self.thurButton.backgroundColor = UIColor.white
        } else {
            dayThur = true
            self.thurButton.backgroundColor = UIColor.lightGray
        }
        print(dayThur)
    }
    @IBAction func friSwitch(_ sender: Any) {
        if (dayFri) {
            dayFri = false
            self.friButton.backgroundColor = UIColor.white
        } else {
            dayFri = true
            self.friButton.backgroundColor = UIColor.lightGray
        }
        print(dayFri)
    }
    @IBAction func satSwitch(_ sender: Any) {
        if (daySat) {
            daySat = false
            self.satButton.backgroundColor = UIColor.white
        } else {
            daySat = true
            self.satButton.backgroundColor = UIColor.lightGray
        }
        print(daySat)
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
