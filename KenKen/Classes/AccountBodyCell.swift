//
//  AccountBodyCell.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/8/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

class AccountBodyCell: UITableViewCell {
    
    
    @IBOutlet var boldLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dotLabel: UILabel!
    
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
