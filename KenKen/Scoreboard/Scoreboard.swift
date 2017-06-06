//
//  Scoreboard.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/21/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Firebase

/*
 
 // The root of the tree
 {
 "global-times": {
 
    // global-times/15
    "15": {
 
        // global-times/15/name
        "name": "Milk",
 
        // grocery-items/milk/addedByUser
        "addedByUser": "Chris"
    },
 
    "pizza": {
        "name": "Pizza",
        "addedByUser": "Alice"
    },
 }
 }
 
 
 */

class Scoreboard: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let challengeArray = ["Challenge: Easy", "Challenge: Medium", "Challenge: Hard"]
    var difficultyArray = [["Easy", "Easy", "Medium"], ["Easy", "Medium", "Hard"], ["Easy", "Medium", "Hard"]]
    
    var timesArray:[[[Int]]] = [[[],[],[]], [[],[],[]], [[],[],[]]]
    
    var easyArray:[Int] = []
    var mediumArray:[Int] = []
    var hardArray:[Int] = []
    
    func formatScoreBoard() {
        
    }
    
    func saveTimes() {
        
        // Sort array
        for i in 0...timesArray.count-1 {
            for j in 0...timesArray[i].count-1{
                timesArray[i][j] = timesArray[i][j].sorted()
            }
        }
        
        // Save array
        let defaults = UserDefaults.standard
        defaults.set(timesArray, forKey: "scoreBoardArray")
        
    }
    
    func setTimes() {
        let defaults = UserDefaults.standard
        
        // Times Array (Challenges)
        if let timesExist = defaults.object(forKey: "scoreBoardArray") {
           timesArray = timesExist as! [[[Int]]]
        } else {
            defaults.set(timesArray, forKey: "scoreBoardArray")
        }
        
        // Easy Array
        if let timesExist = defaults.object(forKey: "easyArray") {
            easyArray = timesExist as! [Int]
        } else {
            defaults.set(easyArray, forKey: "easyArray")
        }
        
        // Medium Array
        if let timesExist = defaults.object(forKey: "mediumArray") {
            mediumArray = timesExist as! [Int]
        } else {
            defaults.set(mediumArray, forKey: "mediumArray")
        }
        
        // Hard Array
        if let timesExist = defaults.object(forKey: "hardArray") {
            hardArray = timesExist as! [Int]
        } else {
            defaults.set(hardArray, forKey: "hardArray")
        }
    }
    
    func addTime(difficulty:String, seconds:Int) {
        let defaults = UserDefaults.standard
        
        if difficulty == "Easy" {
            easyArray.append(seconds)
            easyArray.sort()
            defaults.set(easyArray, forKey: "easyArray")
            
        } else if difficulty == "Medium" {
            mediumArray.append(seconds)
            mediumArray.sort()
            defaults.set(mediumArray, forKey: "mediumArray")
            
        } else {
            hardArray.append(seconds)
            hardArray.sort()
            defaults.set(hardArray, forKey: "hardArray")
        }
        self.addToTotalScore(time: seconds)
        
        // Update user best time
        if Auth.auth().currentUser != nil {appDelegate.user!.updateBestTime(newTime: seconds, diff: difficulty)}
    }
    
    func addToTotalScore(time: Int) {
        if time < 60 && time >= 40 {
            starRank.addToRank(num: 1)
        } else if time < 40 && time >= 25 {
            starRank.addToRank(num: 3)
        } else if time < 25 {
            starRank.addToRank(num: 10)
        }
    }


}
