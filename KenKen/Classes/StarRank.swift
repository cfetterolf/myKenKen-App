//
//  starRank.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/28/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class StarRank: NSObject {
    
    var totalRank: Int
    
    override init() {
        totalRank = 0
    }
    
    func addToRank(num:Int) {
        totalRank += num
        let defaults = UserDefaults.standard
        defaults.set(totalRank, forKey: "starRank")
    }
    
    func setRank() {
        let defaults = UserDefaults.standard
        if let rankExists = defaults.object(forKey: "starRank") {
            totalRank = rankExists as! Int
        } else {
            defaults.set(totalRank, forKey: "starRank")
        }
    }

}
