//
//  SudokuCell.swift
//  KenKen
//
//  Created by Chris Fetterolf on 10/31/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class KenKenCell: NSObject {

    private var value: Int
    private var filled: Bool
    private var tried: [Int]
    
    override init() {
        filled = false
        tried = [Int]()
        value = 0
    }
    
    func isFilled() -> Bool {
        return filled
    }
    
    func get() -> Int {
        return value
    }
    
    func set(number:Int) {
        filled = true
        value = number
        tried.append(number)
    }
    
    func clear() {
        value = 0
        filled = false
    }
    
    func reset() {
        self.clear()
        tried = [Int]()
    }
    
    func show() {
        filled = true
    }
    
    func hide() {
        filled = false
    }
    
    func isTried(number:Int) -> Bool {
        return tried.contains(number)
    }
    
    func tryNumber(number:Int) {
        tried.append(number)
    }
    
    func numberOfTried() -> Int {
        return tried.count
    }
    
}
