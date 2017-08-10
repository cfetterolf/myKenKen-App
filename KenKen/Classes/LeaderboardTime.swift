//
//  LeaderboardTime.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/10/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

class LeaderboardTime: NSObject {

    public var time:Int
    public var name: String
    public var avatar: String
    
    init(time:Int, name:String, avatar:String) {
        self.time = time
        self.name = name
        self.avatar = avatar
    }
    
}
