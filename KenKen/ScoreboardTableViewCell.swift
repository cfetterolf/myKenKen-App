//
//  ScoreboardTableViewCell.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/28/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class ScoreboardTableViewCell: UITableViewCell {

    @IBOutlet var totalScoreLabel: UILabel!
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var starRank: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
