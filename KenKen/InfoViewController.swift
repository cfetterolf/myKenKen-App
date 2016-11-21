//
//  InfoViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/20/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet var challengeTitle: UILabel!
    @IBOutlet var challengeDescription: UILabel!
    @IBOutlet var challengeLabel1: UILabel!
    @IBOutlet var challengeLabel2: UILabel!
    @IBOutlet var challengeLabel3: UILabel!
    @IBOutlet var gradBG: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        InfoBG.layer.cornerRadius = 20.0
        InfoBG.layer.borderColor = UIColor.black.cgColor
        InfoBG.layer.borderWidth = 0.25
        InfoBG.layer.shadowColor = UIColor.black.cgColor
        InfoBG.layer.shadowOpacity = 0.6
        InfoBG.layer.shadowRadius = 15
        InfoBG.layer.shadowOffset = CGSize(width: 5, height: 5)
        InfoBG.layer.masksToBounds = false
        gradBG.layer.cornerRadius = 20.0
        gradBG.clipsToBounds = true
        gradBG.layer.borderColor = UIColor.black.cgColor
        gradBG.layer.borderWidth = 0.25
        
        challengeTitle.text = "Challenge: \(selectedDiff)"
        setDescription(diff: selectedDiff)
        
    }
    
    @IBAction func changeBool(_ sender: Any) {
        performSG = true
        print(performSG)
    }
    
    
    func setDescription(diff: String) {
        if diff == "Easy" {
            let description = "To beat this challenge, you must solve 3 puzzles in a row within their respective time limits."
            challengeDescription.text = description
            challengeLabel1.text = "Difficulty: Easy  \nTime Limit: 1:30"
            challengeLabel2.text = "Difficulty: Easy  \nTime Limit: 1:15"
            challengeLabel3.text = "Difficulty: Medium  \nTime Limit: 2:30"
        
        } else if diff == "Medium" {
            let description = "To beat this challenge, you must solve 3 puzzles in a row within their respective time limits."
            challengeDescription.text = description
            challengeLabel1.text = "Difficulty: Easy  \nTime Limit: 1:00"
            challengeLabel2.text = "Difficulty: Medium  \nTime Limit: 1:30"
            challengeLabel3.text = "Difficulty: Hard  \nTime Limit: 2:30"

        } else if diff == "Hard" {
            let description = "To beat this challenge, you must solve 3 puzzles in a row within their respective time limits."
            challengeDescription.text = description
            challengeLabel1.text = "Difficulty: Easy  \nTime Limit: 0:30"
            challengeLabel2.text = "Difficulty: Medium  \nTime Limit: 1:00"
            challengeLabel3.text = "Difficulty: Hard  \nTime Limit: 1:30"
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBOutlet var InfoBG: UIView!

}
