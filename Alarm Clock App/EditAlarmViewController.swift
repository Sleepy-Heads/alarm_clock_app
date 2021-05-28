//
//  EditAlarmViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/28/21.
//

import UIKit

class EditAlarmViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    //needed for dark mode
    @IBOutlet weak var editAlarmLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var puzzleLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    //
    
    
    @IBOutlet weak var alarmNametxt: UITextField!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var monButton: UIButton!
    @IBOutlet weak var tueButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var thurButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var satButton: UIButton!
    
    private let notificationPublisher = NotificationPublisher()
    
    let difficultyOptions = ["Easy", "Normal", "Hard"]
    let puzzleOptions = ["Math Equations", "Scrambled Word Sentence", "Scrambled Letter Sentence"]
    var puzzleDifficultyPickerView = UIPickerView()
    var puzzleTypePickerView = UIPickerView()
    
    @IBOutlet weak var puzzleTextField: UITextField!
    @IBOutlet weak var difficultyTextField: UITextField!
    
    var alarmsEditScreen : [Alarm] = []
    var daySun = false
    var dayMon = false
    var dayTue = false
    var dayWed = false
    var dayThur = false
    var dayFri = false
    var daySat = false
    
    var time = "12:00 AM"
    var amOrPm = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        puzzleTextField.inputView = puzzleTypePickerView
        difficultyTextField.inputView = puzzleDifficultyPickerView
        
        puzzleTextField.placeholder = "Select a puzzle"
        difficultyTextField.placeholder = "Select the difficulty"
        puzzleDifficultyPickerView.dataSource = self
        puzzleDifficultyPickerView.delegate = self
        puzzleTypePickerView.dataSource = self
        puzzleTypePickerView.delegate = self

        puzzleTypePickerView.tag = 1
        puzzleDifficultyPickerView.tag = 2
        
        
        if defaults.bool(forKey: "darkModeToggleOn") {
            editAlarmLabel.textColor = .black
            nameLabel.textColor = .black
            timeLabel.textColor = .black
            repeatLabel.textColor = .black
            sunButton.setTitleColor(.black, for: .normal)
            monButton.setTitleColor(.black, for: .normal)
            tueButton.setTitleColor(.black, for: .normal)
            wedButton.setTitleColor(.black, for: .normal)
            thurButton.setTitleColor(.black, for: .normal)
            friButton.setTitleColor(.black, for: .normal)
            satButton.setTitleColor(.black, for: .normal)
            puzzleLabel.textColor = .black
            difficultyLabel.textColor = .black
        }
    }
    
    @IBAction func onTimeSelected(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        time = dateFormatter.string(from: timePicker.date)
    }
    
    @IBAction func onDone(_ sender: Any) {
        let name = alarmNametxt.text != "" ? alarmNametxt.text! : "Alarm"
        let week = [daySun, dayMon, dayTue, dayWed, dayThur, dayFri, daySat]
        let toggle = true
        amOrPm = String(time.suffix(2))
        time.removeLast(3)
        let key = UUID().uuidString
        let alarm = Alarm(alarmName: name, alarmTime: time, alarmPeriod: amOrPm, alarmDays: week, alarmToggle: toggle, alarmPuzzleType: puzzleTextField.text!, alarmPuzzleDiff: difficultyTextField.text!, alarmKey: key)
        Defaults.addAlarm(alarm: alarm)
        notificationPublisher.sendNotification(alarm: alarm, badge: 1)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sunSwitch(_ sender: Any) {
        if (daySun) {
            daySun = false
            self.sunButton.backgroundColor = UIColor(named: "cantaloupe")
        } else {
            daySun = true
            self.sunButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func monSwitch(_ sender: Any) {
        if (dayMon) {
            dayMon = false
            self.monButton.backgroundColor = UIColor(named: "cantaloupe")
        } else {
            dayMon = true
            self.monButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func tueSwitch(_ sender: Any) {
        if (dayTue) {
            dayTue = false
            self.tueButton.backgroundColor = UIColor(named: "cantaloupe")
        } else {
            dayTue = true
            self.tueButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func wedSwitch(_ sender: Any) {
        if (dayWed) {
            dayWed = false
            self.wedButton.backgroundColor = UIColor(named: "cantaloupe")
        } else {
            dayWed = true
            self.wedButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func thurSwitch(_ sender: Any) {
        if (dayThur) {
            dayThur = false
            self.thurButton.backgroundColor = UIColor(named: "cantaloupe")
        } else {
            dayThur = true
            self.thurButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func friSwitch(_ sender: Any) {
        if (dayFri) {
            dayFri = false
            self.friButton.backgroundColor = UIColor(named: "cantaloupe")
        } else {
            dayFri = true
            self.friButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func satSwitch(_ sender: Any) {
        if (daySat) {
            daySat = false
            self.satButton.backgroundColor = UIColor(named: "cantaloupe")
        } else {
            daySat = true
            self.satButton.backgroundColor = UIColor.white
        }
    }
}

extension EditAlarmViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return puzzleOptions.count
        case 2:
            return difficultyOptions.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return puzzleOptions[row]
        case 2:
            return difficultyOptions[row]
        default:
            return "Data not found."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            puzzleTextField.text = puzzleOptions[row]
            puzzleTextField.resignFirstResponder()
        case 2:
            difficultyTextField.text = difficultyOptions[row]
            difficultyTextField.resignFirstResponder()
        default:
            return
        }
    }
}

