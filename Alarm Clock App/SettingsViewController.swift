//
//  SettingsViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/28/21.
//

/*
 TO DO:
 - Implement dark mode
 - Notify when they terminate feature? OPTIONAL
 - Wallpeper feature? OPTIONAL
 */
import UIKit


class SettingsViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var timerSegmentedControl: UISegmentedControl!
    @IBOutlet weak var militaryTimeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var twentyFourTimeLabel: UILabel!
    @IBOutlet weak var notifyUponTerminationLabel: UILabel!
    @IBOutlet weak var firstViewSlot: UIView!
    @IBOutlet weak var secondViewSlot: UIView!
    @IBOutlet weak var thirdViewSlot: UIView!
    @IBOutlet weak var fourthViewSlot: UIView!
    
    
    
    var selectedName: String = "Anonymous"
    
    var timerValues = [10, 15, 20, 30, 40, 50, 60]
    var selectedTime : Int = 10
    
    var militaryTimeOn = false
    
    
    override func viewDidLoad() {
        
        //enabling persistence for timer segmented control
        let amountOfTimeForPuzzle = defaults.integer(forKey: "timeSelected")
        if amountOfTimeForPuzzle != 0 {
            timerSegmentedControl.selectedSegmentIndex = timerValues.firstIndex(of: amountOfTimeForPuzzle)!
        }
        
        if defaults.bool(forKey: "darkModeToggleOn") == true {
            darkModeSwitch.setOn(true, animated: false)
            
            overrideUserInterfaceStyle = .dark
            timeLimitLabel.textColor = .white
            twentyFourTimeLabel.textColor = .white
            darkModeLabel.textColor = .white
            notifyUponTerminationLabel.textColor = .white
            
            firstViewSlot.backgroundColor = .black
            secondViewSlot.backgroundColor = .black
            thirdViewSlot.backgroundColor = .black
            fourthViewSlot.backgroundColor = .black
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        militaryTimeSwitch.isOn = defaults.bool(forKey: "militaryTimeToggleOn")
    }
    
    @IBAction func onTimerChanged(_ sender: Any) {
        self.selectedTime = timerValues[timerSegmentedControl.selectedSegmentIndex]
        
        defaults.set(selectedTime, forKey: "timeSelected")
        defaults.synchronize()
        
    }
    
    
    
    @IBAction func onDarkModeToggle(_ sender: Any) {
        if darkModeSwitch.isOn {
            defaults.set(true, forKey: "darkModeToggleOn")
            overrideUserInterfaceStyle = .dark
            timeLimitLabel.textColor = .white
            twentyFourTimeLabel.textColor = .white
            darkModeLabel.textColor = .white
            notifyUponTerminationLabel.textColor = .white
            
            firstViewSlot.backgroundColor = .black
            secondViewSlot.backgroundColor = .black
            thirdViewSlot.backgroundColor = .black
            fourthViewSlot.backgroundColor = .black
        } else {
            defaults.set(false, forKey: "darkModeToggleOn")
            overrideUserInterfaceStyle = .light
            timeLimitLabel.textColor = .black
            twentyFourTimeLabel.textColor = .black
            darkModeLabel.textColor = .black
            notifyUponTerminationLabel.textColor = .black
            
            firstViewSlot.backgroundColor = .white
            secondViewSlot.backgroundColor = .white
            thirdViewSlot.backgroundColor = .white
            fourthViewSlot.backgroundColor = .white
            
        }
    }
    
    @IBAction func onMilitaryTimeToggle(_ sender: Any) {
        if militaryTimeSwitch.isOn {
            defaults.set(true, forKey: "militaryTimeToggleOn")
        } else {
            defaults.set(false, forKey: "militaryTimeToggleOn")
        }
        defaults.synchronize()
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


