//
//  AlarmCell.swift
//  Alarm Clock App
//
//  Created by Paul Sayad on 5/5/21.
//

import UIKit

class AlarmCell: UITableViewCell {

    
    @IBOutlet weak var alarmTime: UILabel!
    @IBOutlet weak var alarmName: UILabel!
    @IBOutlet weak var alarmPeriod: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
