//
//  Challenge.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/21/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class Challenge: NSObject {
    
    var initCountdownArray:[Int]
    var difficultyArray:[String]
    var numberPuzzles: Int
    var nextPuzzleIndex = 0
    var timeFinishedArray:[Int]
    
    init(countdownArray: [Int], diffArray:[String], numPuzzles:Int) {
        initCountdownArray = countdownArray
        difficultyArray = diffArray
        numberPuzzles = numPuzzles
        timeFinishedArray = []
    }
    
    func restart() {
        nextPuzzleIndex = 0
        timeFinishedArray = []
    }
    

}
