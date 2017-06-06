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
    public var bestArray:[Int]
    public var easyArray:[Int]
    public var mediumArray:[Int]
    public var hardArray:[Int]
    
    init(email:String, name:String, surname:String, password:String) {
        userEmail=email
        userName=name
        userSurname=surname
        userPassword=password
        bestArray = []
        easyArray = []
        mediumArray = []
        hardArray = []
    }
    
    func updateBestTime(newTime:Int, diff:String) {
        let ref = Database.database().reference(withPath: "users/\((Auth.auth().currentUser?.uid)!)")
        
        //Update diff arrays
        bestArray.append(newTime)
        bestArray.sort()
        
        switch diff {
        case "Easy":
            easyArray.append(newTime)
            easyArray.sort()
        case "Medium":
            mediumArray.append(newTime)
            mediumArray.sort()
        default:
            hardArray.append(newTime)
            hardArray.sort()
        }
        
        ref.setValue(self.toAnyObject())
    }
    
    func toAnyObject() -> Any {
        return [
            "email": userEmail,
            "name": userName,
            "surname": userSurname,
            "password": userPassword,
            "best-array": bestArray,
            "easy-array": easyArray,
            "medium-array": mediumArray,
            "hard-array": hardArray
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
    
    
    func logIn() {
        print("LOG IN")
        let ref = Database.database().reference(withPath: "users/\((Auth.auth().currentUser?.uid)!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            let value = snapshot.value as! NSDictionary
            print(value)
            self.userEmail = value["email"] as! String
            self.userName = value["name"] as! String
            self.userSurname = value["surname"] as! String
            self.userPassword = value["password"] as! String
            
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
            self.printUserData()
        })

    }
    

}
