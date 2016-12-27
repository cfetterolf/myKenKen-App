//
//  MyCustomCellTableViewCell.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/10/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class MyCustomCell: UITableViewCell {

    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
   
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
