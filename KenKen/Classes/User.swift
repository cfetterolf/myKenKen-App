//
//  User.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/1/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

class User: NSObject {
    
    public var userEmail:String
    public var userName:String
    public var userSurname:String
    public var userPassword:String
    public var bestTime:Int
    
    init(email:String, name:String, surname:String, password:String) {
        userEmail=email
        userName=name
        userSurname=surname
        userPassword=password
        bestTime = 10000
    }
    
    func toAnyObject() -> Any {
        return [
            "email": userEmail,
            "name": userName,
            "surname": userSurname,
            "password": userPassword,
            "best-time": bestTime
        ]
    }

    

}
