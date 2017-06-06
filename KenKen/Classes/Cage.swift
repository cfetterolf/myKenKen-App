//
//  Cage.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/29/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class Cage: NSObject {
    
    var cageSize:Int
    var operation:Int // 0 is +, 1 is x, 2 is -, 3 is div, 4 is self
    var target:Int
    var valuesInCage:[Int]
    
    init(size: Int, code: String) {
        
        cageSize = size
        
        let opArr:[Character] = ["+","x","-","÷"]
        
        if opArr.contains(code.characters.last!) {
            let op = code.characters.last
            var tar = code
            tar.remove(at: tar.index(before: tar.endIndex))
            
            if op == "+" {
                operation = 0
            } else if op == "x"{
                operation = 1
            } else if op == "-" {
                operation = 2
            } else {
                operation = 3
            }
            target = Int(tar)!
        } else {
            operation = 4
            target = Int(code)!
        }
        
        valuesInCage = [Int](repeating: -100, count: size)
        
    }
    
    func cageWillAccept() -> Bool {

        if operation == 0 {
            var total = 0
            for value in valuesInCage {
                total += value
            }
            if total == target {
                return true
            } else {
                return false
            }
        } else if operation == 1 {
            var total = 1
            for value in valuesInCage {
                total *= value
            }
            if total == target {
                return true
            } else {
                return false
            }
        } else if operation == 2 {
            let total = valuesInCage.max()! - valuesInCage.min()!
            if total == target {
                return true
            } else {
                return false
            }
        } else if operation == 3 {
            let total = valuesInCage.max()! / valuesInCage.min()!
            if total == target {
                return true
            } else {
                return false
            }
        } else {
            if valuesInCage[0] == target {
                return true
            } else {
                return false
            }
        }
    }

}
