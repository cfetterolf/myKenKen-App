//
//  ScoreboardGlobal.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/9/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit
import Firebase


class ScoreboardGlobal: NSObject {
    
    var name:String
    var time:Int
    var avatar:String
    
    init(name:String, time:Int, avatar:String) {
        self.name = name
        self.time = time
        self.avatar = avatar
    }

//    func updateLeaderboard(time:Int, diff:String) {
//        
//        if Auth.auth().currentUser == nil {return}
//        
//        let ref = Database.database().reference(withPath: "leaderboard")
//        let bestRef = ref.child("best-leaderboard")
//        let easyRef = ref.child("easy-leaderboard")
//        let mediumRef = ref.child("medium-leaderboard")
//        let hardRef = ref.child("hard-leaderboard")
//        
//        //Update Best Array
//        let bestRefChild = bestRef.child((Auth.auth().currentUser?.uid)!)
//        bestRefChild.setValue(self.toAnyObject(), andPriority: "time")
//    }
//    
    

    
}
