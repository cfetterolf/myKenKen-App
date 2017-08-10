//
//  LeaderboardCell.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/11/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {
    
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarLabel: UIImageView!
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
