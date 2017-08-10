//
//  User.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/1/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
    
    public var userEmail:String
    public var userName:String
    public var userSurname:String
    public var userPassword:String
    public var userAvatar:String
    public var bestArray:[Int]
    public var easyArray:[Int]
    public var mediumArray:[Int]
    public var hardArray:[Int]
    
    init(email:String, name:String, surname:String, password:String) {
        userEmail=email
        userName=name
        userSurname=surname
        userPassword=password
        userAvatar = "steph"
        bestArray = []
        easyArray = []
        mediumArray = []
        hardArray = []
    }
    
    func updateBestTime(newTime:Int, diff:String) {
        let ref = Database.database().reference(withPath: "users/\((Auth.auth().currentUser?.uid)!)")
        //UPDATE GLOBAL LEADERBOARDS
        let leaderBoardRef = Database.database().reference(withPath: "leaderboard")
        let bestRef = leaderBoardRef.child("best-leaderboard")
        let easyRef = leaderBoardRef.child("easy-leaderboard")
        let mediumRef = leaderBoardRef.child("medium-leaderboard")
        let hardRef = leaderBoardRef.child("hard-leaderboard")
        
        
        //Update diff arrays
        
        bestArray.append(newTime)
        bestArray.sort()
        //Update Best Array Global
        let bestRefChild = bestRef.child((Auth.auth().currentUser?.uid)!)
        bestRefChild.setValue(toLeaderboardObject(name: self.userName, avatar: self.userAvatar, time: bestArray[0]), andPriority: "time")
        
        switch diff {
        case "Easy":
            easyArray.append(newTime)
            easyArray.sort()
            //Update Easy Array Global
            let easyRefChild = easyRef.child((Auth.auth().currentUser?.uid)!)
            easyRefChild.setValue(toLeaderboardObject(name: self.userName, avatar: self.userAvatar, time: easyArray[0]), andPriority: "time")
        case "Medium":
            mediumArray.append(newTime)
            mediumArray.sort()
            //Update Medium Array Global
            let mediumRefChild = mediumRef.child((Auth.auth().currentUser?.uid)!)
            mediumRefChild.setValue(toLeaderboardObject(name: self.userName, avatar: self.userAvatar, time: mediumArray[0]), andPriority: "time")
        default:
            hardArray.append(newTime)
            hardArray.sort()
            //Update Hard Array Global
            let hardRefChild = hardRef.child((Auth.auth().currentUser?.uid)!)
            hardRefChild.setValue(toLeaderboardObject(name: self.userName, avatar: self.userAvatar, time: hardArray[0]), andPriority: "time")
        }
        
        ref.setValue(self.toAnyObject())
        
    }
    
    func toAnyObject() -> Any {
        return [
            "email": userEmail,
            "name": userName,
            "surname": userSurname,
            "password": userPassword,
            "avatar": userAvatar,
            "best-array": bestArray,
            "easy-array": easyArray,
            "medium-array": mediumArray,
            "hard-array": hardArray
        ]
    }
    
    func toLeaderboardObject(name:String, avatar:String, time:Int) -> Any {
        return [
            "name": name,
            "avatar": avatar,
            "time": time
        ]
    }
    
    
    func printUserData() {
        print("-----------")
        print(userEmail)
        print(userName)
        print(userSurname)
        print(userPassword)
        print(bestArray)
        print(easyArray)
        print(mediumArray)
        print(hardArray)
        print("-----------")
    }
    
    typealias CompletionHandler = () -> Void
    
    func logIn(completionHandler: @escaping CompletionHandler) {
        print("LOG IN")
        let ref = Database.database().reference(withPath: "users/\((Auth.auth().currentUser?.uid)!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            let value = snapshot.value as! NSDictionary
            
            self.userEmail = value["email"] as! String
            self.userName = value["name"] as! String
            self.userSurname = value["surname"] as! String
            self.userPassword = value["password"] as! String
            self.userAvatar = value["avatar"] as! String
            
            //May not be init in Firebase yet
            if let bestArr = value.object(forKey: "best-array") {
                self.bestArray = bestArr as! [Int]
            } 
            if let easyArr = value.object(forKey: "easy-array") {
                self.easyArray = easyArr as! [Int]
            }
            if let mediumArr = value.object(forKey: "medium-array") {
                self.mediumArray = mediumArr as! [Int]
            }
            if let hardArr = value.object(forKey: "hard-array") {
                self.hardArray = hardArr as! [Int]
            }
            
            completionHandler()
        })

    }
    

}
