//
//  ViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/26/21.
//

import UIKit
import UserNotifications
import AVFoundation
var player: AVAudioPlayer!

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var sleepMode: UIView!
    var sleepModeToggle = false
    
    var alarmsHomeScreen = Defaults.getAlarmObjects()
    private let notificationPublisher = NotificationPublisher()
    
    var puzzleType = "Math Equations"
    var difficultyLevel = "Easy"
    
    //for military time feature
    let defaults = UserDefaults.standard
    
    // Notification Center
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(named: "cantaloupe")
        // Do any additional setup after loading the view.
        
        let TapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(TapGesture)
        TapGesture.addTarget(self, action: #selector(disableSleep))
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    // After an alarm is made, it will refresh and show the alarm
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmsHomeScreen.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell") as! AlarmCell
        let alarm = alarmsHomeScreen[indexPath.row]
        
        cell.selectionStyle = .none
        cell.alarmTime.text = alarm.alarmTime
        cell.alarmPeriod.text = alarm.alarmPeriod
        
        if(alarm.alarmDays.filter{$0}.count == 0){
            cell.alarmName.text = alarm.alarmName
        } else if(alarm.alarmDays.filter{$0}.count == 7) {
            cell.alarmName.text = alarm.alarmName + ", every day"
        } else if(alarm.alarmDays.filter{$0}.count == 2 && alarm.alarmDays[0] && alarm.alarmDays[6]) {
            cell.alarmName.text = alarm.alarmName + ", every weekend"
        }  else if(alarm.alarmDays.filter{$0}.count == 5 && !alarm.alarmDays[0] && !alarm.alarmDays[6]) {
            cell.alarmName.text = alarm.alarmName + ", every weekday"
        } else if(alarm.alarmDays.filter{$0}.count == 1){
            var day = ""
            let longDays = [" Sunday", " Monday", " Tuesday", " Wednesday", " Thursday", " Friday", "Saturday"]
            for i in alarm.alarmDays.enumerated() {
                if(i.element){
                    day = longDays[i.offset]
                }
            }
            cell.alarmName.text = alarm.alarmName + ", every" + day
        } else {
            var days = ""
            let shortDays = [" Sun", " Mon", " Tue", " Wed", " Thu", " Fri", " Sat"]
            for i in alarm.alarmDays.enumerated() {
                if(i.element){
                    days += shortDays[i.offset]
                }
            }
            cell.alarmName.text = alarm.alarmName + "," + days
        }
            
        let switchView = UISwitch(frame: .zero)
        
        if(alarm.alarmToggle) {
            switchView.setOn(true, animated: true)
        } else {
            switchView.setOn(false, animated: true)
        }
        
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        
        //checking if military time is enabled
        let militaryTimeOn = defaults.bool(forKey: "militaryTimeToggleOn")
        if militaryTimeOn && !alarmsHomeScreen.isEmpty {
            if cell.alarmPeriod.text == "PM" && cell.alarmTime.text?.prefix(2) != "12" {
                if convertStringMinutesToInt(cell.alarmTime.text!) == -1{
                    cell.alarmTime.text = "\(convertStringHourToInt(cell.alarmTime.text!) + 12):00"
                } else {
                    cell.alarmTime.text = "\(convertStringHourToInt(cell.alarmTime.text!) + 12):\(convertStringMinutesToInt(cell.alarmTime.text!))"
                }
            }
            
            if cell.alarmTime.text?.prefix(2) == "12" && cell.alarmPeriod.text == "AM" {
                if convertStringMinutesToInt(cell.alarmTime.text!) == -1{
                    cell.alarmTime.text = "0:00"
                } else {
                    cell.alarmTime.text = "0:\(convertStringMinutesToInt(cell.alarmTime.text!))"
                }
            }
        }
        //done checking
        
        
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
        print(sender.tag)
        if(alarmsHomeScreen[sender.tag].alarmToggle){
            alarmsHomeScreen[sender.tag].alarmToggle = false
            Defaults.updateAlarmObject(index: sender.tag, alarm: alarmsHomeScreen[sender.tag])
            
            // Alarm won't trigger notification
            if(self.alarmsHomeScreen[sender.tag].alarmDays.filter{$0}.count == 0) {
                self.center.removeDeliveredNotifications(withIdentifiers: [self.alarmsHomeScreen[sender.tag].alarmKey])
                self.center.removePendingNotificationRequests(withIdentifiers: [self.alarmsHomeScreen[sender.tag].alarmKey])
            } else {
                let days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
                for i in self.alarmsHomeScreen[sender.tag].alarmDays.enumerated() {
                    if(i.element){
                        self.center.removeDeliveredNotifications(withIdentifiers: [self.alarmsHomeScreen[sender.tag].alarmKey + days[i.offset]])
                        self.center.removePendingNotificationRequests(withIdentifiers: [self.alarmsHomeScreen[sender.tag].alarmKey + days[i.offset]])
                    }
                }
            }
        } else {
            alarmsHomeScreen[sender.tag].alarmToggle = true
            Defaults.updateAlarmObject(index: sender.tag, alarm: alarmsHomeScreen[sender.tag])
            notificationPublisher.sendNotification(alarm: alarmsHomeScreen[sender.tag], badge: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, actionPerformed: (Bool) -> Void) in
            
            // Deletes the alarm from local notifications
            if(self.alarmsHomeScreen[indexPath.row].alarmDays.filter{$0}.count == 0) {
                self.center.removeDeliveredNotifications(withIdentifiers: [self.alarmsHomeScreen[indexPath.row].alarmKey])
                self.center.removePendingNotificationRequests(withIdentifiers: [self.alarmsHomeScreen[indexPath.row].alarmKey])
            } else {
                let days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
                for i in self.alarmsHomeScreen[indexPath.row].alarmDays.enumerated() {
                    if(i.element){
                        self.center.removeDeliveredNotifications(withIdentifiers: [self.alarmsHomeScreen[indexPath.row].alarmKey + days[i.offset]])
                        self.center.removePendingNotificationRequests(withIdentifiers: [self.alarmsHomeScreen[indexPath.row].alarmKey + days[i.offset]])
                    }
                }
            }
            
            // Deletes alarm in alarmsHomeScreen array
            self.alarmsHomeScreen.remove(at: indexPath.row)
            //print(self.alarmsHomeScreen.count)
            
            // Deletes alarm in defaults
            Defaults.deleteAlarmObject(index: indexPath.row)
            
            // Deletes alarm from tableview
            tableView.deleteRows(at: [indexPath], with: .automatic)
            actionPerformed(true)
        }
                
        return UISwipeActionsConfiguration(actions: [delete])
    }
    

    @IBAction func enableSleep(_ sender: Any) {
        UIApplication.shared.isIdleTimerDisabled = true
        sleepMode.bounds = self.view.bounds
        if(sleepModeToggle == false){
            animateIn(desiredView: sleepMode)
            sleepModeToggle = true
        }
    }
    
    @objc func disableSleep(){
        if(sleepModeToggle == true){
            UIApplication.shared.isIdleTimerDisabled = false
            sleepMode.bounds = self.view.bounds
            animateOut(desiredView: sleepMode)
            sleepModeToggle = false
        }
    }
    
    func playAlarmSound() {
        let urlString = Bundle.main.path(forResource: "buzzer", ofType: "mp3")
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
            guard let urlString = urlString else { return }

            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
                
            guard let player = player else { return }
            player.numberOfLoops = -1
            player.play()
        } catch {
            print(error)
        }
    }
    
    func stopAlarmSound() {
        if let player = player, player.isPlaying {
            player.stop()
        }
    }
            
    //needed for military time feature
    func convertStringHourToInt(_ time: String) -> Int {
        let length : Int = time.count
        var hour : Int = 0
        
        if length == 4 {
            //2:00 for ex.
            hour = Int(time.prefix(1))!
        } else {
            //12:00 for ex.
            hour = Int(time.prefix(2))!
        }
        return hour
    }
    
    //needed for military time feature, returns -1 if minutes is 00
    func convertStringMinutesToInt(_ time: String) -> Int {
        var minutes : Int = 0
        
        minutes = Int(time.suffix(2))!
        if time.suffix(2) == "00" {
            minutes = -1
        }
        return minutes
    }
    
    // Animate in a specified view
    func animateIn(desiredView: UIView) {
        let backgroundView = self.view!

        // attach our desired view to the screen (self.view/backgroundView)
        backgroundView.addSubview(desiredView)

        // Sets the views scaling to be 120%
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0
        desiredView.center = backgroundView.center

        // animate the effect
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
        })
    }

    // animate out a specified view
    func animateOut(desiredView: UIView) {
        // animate the effect
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            desiredView.alpha = 0
        }, completion: { _ in
            desiredView.removeFromSuperview()
        })
    }
    
    func getPuzzleAndDifficulty(systemTime : String) {
        for alarm in alarmsHomeScreen.enumerated(){
            let alarm = alarmsHomeScreen[alarm.offset]
            let currentAlarm = alarm.alarmTime + alarm.alarmPeriod
            print(currentAlarm, " ", systemTime)
            if(currentAlarm == systemTime){
                print("found it")
                puzzleType = alarm.alarmPuzzleType
                difficultyLevel = alarm.alarmPuzzleDiff
            }
        }
        
        print("In func: ", puzzleType)
        print("In func: ", difficultyLevel)
    }
    
    func getPuzzleType() -> String {
        print("in get:", puzzleType)
        return puzzleType
    }
    
    func getDifficultyLevel() -> String {
        print("in 2nd get:", difficultyLevel)
        return difficultyLevel
    }
    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        print("Before: ", puzzleType)
//        print("Before: ", difficultyLevel)
//        let SolveAlarmViewController = segue.destination as? ViewController
//        SolveAlarmViewController?.puzzleType = puzzleType
//        SolveAlarmViewController?.difficultyLevel = difficultyLevel
//    }
}


