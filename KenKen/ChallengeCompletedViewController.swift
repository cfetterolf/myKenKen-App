//
//  ChallengeCompletedViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/21/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class ChallengeCompletedViewController: UIViewController {
    @IBOutlet var challengeTitle: UILabel!
    @IBOutlet var challengeDescription: UILabel!
    @IBOutlet var challengeLabel1: UILabel!
    @IBOutlet var challengeLabel2: UILabel!
    @IBOutlet var challengeLabel3: UILabel!
    @IBOutlet var gradBG: UIImageView!
    @IBOutlet var scoreEarnedLabel: UILabel!
    
    var index = 0
    var scoreEarned = 0
    
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
        
        challengeTitle.text = "Challenge: Completed"
        performSG = false
        
        if selectedDiff == "Easy" {
            index = 0
            scoreEarned = 10
        } else if selectedDiff == "Medium" {
            index = 1
            scoreEarned = 25
        } else if selectedDiff == "Hard" {
            index = 2
            scoreEarned = 50
        }
        
        scoreEarnedLabel.text = "Score earned from Challenge: \(scoreEarned)"
        
        starRank.addToRank(num: scoreEarned)
        
        setDescription()
        
        scoreBoard.saveTimes()
        
    }
    
    func formatTime(sec: Int) -> String {
        let minutes = sec / 60
        let seconds = sec - (60*minutes)
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        return "\(minutesString):\(secondsString)"
    }
    
    func computeScore(time: Int) -> Int{
        if time < 60 && time >= 40 {
            return 1
        } else if time < 40 && time >= 25 {
            return 3
        } else if time < 25 {
            return 10
        } else {
            return 0
        }

    }

    
    
    func setDescription() {
        let description = "You completed the \(selectedDiff) Challenge.\nBelow are your times and scores for each level."
        challengeDescription.text = description
        challengeLabel1.text = "Difficulty: \(currentChallenge.difficultyArray[0])\nSolved in \(self.formatTime(sec: currentChallenge.timeFinishedArray[0]))\nScore earned: \(computeScore(time: currentChallenge.timeFinishedArray[0]))"
        scoreBoard.timesArray[index][0].append(currentChallenge.timeFinishedArray[0])
        
        challengeLabel2.text = "Difficulty: \(currentChallenge.difficultyArray[1])\nSolved in \(self.formatTime(sec: currentChallenge.timeFinishedArray[1]))\nScore earned: \(computeScore(time: currentChallenge.timeFinishedArray[1]))"
        scoreBoard.timesArray[index][1].append(currentChallenge.timeFinishedArray[1])
        
        challengeLabel3.text = "Difficulty: \(currentChallenge.difficultyArray[2])\nSolved in \(self.formatTime(sec: currentChallenge.timeFinishedArray[2]))\nScore earned: \(computeScore(time: currentChallenge.timeFinishedArray[2]))"
        scoreBoard.timesArray[index][2].append(currentChallenge.timeFinishedArray[2])
    }
    
    @IBAction func changeBool(_ sender: Any) {
        performSGFinish = true
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
