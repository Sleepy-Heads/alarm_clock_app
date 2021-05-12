//
//  ViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/26/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var alarmsHomeScreen = Defaults.getAlarmObjects()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    
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
            for i in alarm.alarmDays.enumerated() {
                if(i.offset == 0 && i.element){
                    day = " Sunday"
                } else if(i.offset == 1 && i.element){
                    day = " Monday"
                } else if(i.offset == 2 && i.element){
                    day = " Tuesday"
                } else if(i.offset == 3 && i.element){
                    day = " Wednesday"
                } else if(i.offset == 4 && i.element){
                    day = " Thursday"
                } else if(i.offset == 5 && i.element){
                    day = " Friday"
                } else if(i.offset == 6 && i.element){
                    day = " Saturday"
                }
            }
            
            cell.alarmName.text = alarm.alarmName + ", every" + day
        } else {
            var days = ""
            for i in alarm.alarmDays.enumerated() {
                if(i.offset == 0 && i.element){
                    days += " Sun"
                } else if(i.offset == 1 && i.element){
                    days += " Mon"
                } else if(i.offset == 2 && i.element){
                    days += " Tue"
                } else if(i.offset == 3 && i.element){
                    days += " Wed"
                } else if(i.offset == 4 && i.element){
                    days += " Thu"
                } else if(i.offset == 5 && i.element){
                    days += " Fri"
                } else if(i.offset == 6 && i.element){
                    days += " Sat"
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
        
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
        if(alarmsHomeScreen[sender.tag].alarmToggle){
            alarmsHomeScreen[sender.tag].alarmToggle = false
        } else {
            alarmsHomeScreen[sender.tag].alarmToggle = true
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, actionPerformed: (Bool) -> Void) in
            self.alarmsHomeScreen.remove(at: indexPath.row)
            Defaults.deleteAlarmObject(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            actionPerformed(true)
        }
                
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    /*
     
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     
    */
}

