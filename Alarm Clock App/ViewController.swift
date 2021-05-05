//
//  ViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/26/21.
//

import UIKit

class ViewController: UIViewController {
    //, UITableViewDelegate, UITableViewDataSource
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var alarmsHomeScreen : [Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.delegate = self
//        tableView.dataSource = self
        // Do any additional setup after loading the view.
    
        if(alarmsHomeScreen.count > 0){
            print("We are in this if statement")
            print(alarmsHomeScreen[0].alarmName)
            print(alarmsHomeScreen[0].alarmTime)
            nameLabel.text = "Hello"
            timeLabel.text = alarmsHomeScreen[0].alarmTime
        }
        
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return 0
//    }
    
}

