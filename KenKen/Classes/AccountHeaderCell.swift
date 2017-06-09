//
//  AccountHeaderCell.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/7/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

class AccountHeaderCell: UITableViewCell {

    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var accountEmailLabel: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}
