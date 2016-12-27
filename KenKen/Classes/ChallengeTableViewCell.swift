//
//  ChallengeTableViewCell.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/19/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

var selectedDiff = ""

class ChallengeTableViewCell: UITableViewCell {

    @IBOutlet var challengeName: UILabel!
    @IBOutlet var challengeDescription: UILabel!
    @IBOutlet var difficultyBG: UIButton!
    @IBAction func choseDifficulty(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1 ,
                       animations: {
                        sender.alpha = 0.6
        },
                       completion: { finish in
                        UIView.animate(withDuration: 0.1){
                            sender.alpha = 1.0
                        }
        })
        
        selectedDiff = challengeName.text!

    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        difficultyBG.layer.cornerRadius = 15.0
        difficultyBG.layer.shadowColor = UIColor.black.cgColor
        difficultyBG.layer.shadowOpacity = 0.5
        difficultyBG.layer.shadowOffset = CGSize.init(width: 3, height: 3)
        difficultyBG.layer.shadowRadius = 3
        difficultyBG.layer.borderColor = UIColor.black.cgColor
        difficultyBG.layer.borderWidth = 0.1
        difficultyBG.layer.masksToBounds = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
