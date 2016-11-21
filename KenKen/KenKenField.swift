//
//  KenKenField.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/1/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class KenKenField: NSObject {

    var blockSize: Int
    var fieldSize: Int
    var field: [[KenKenCell]]
    
    init(blocks: Int) {
        blockSize = blocks
        fieldSize = blockSize * blockSize;
        field = Array<Any>(repeating: Array(repeating: KenKenCell(), count: fieldSize), count: fieldSize) as! [[KenKenCell]]
        for i in 0...fieldSize-1 {
            for j in 0...fieldSize-1 {
                field[i][j] = KenKenCell()
            }
        }
    }
    
    func variantsPerCell() -> Int {
        return fieldSize
    }
    
    func numberOfCells() -> Int {
        return fieldSize * fieldSize
    }
    
    func clear(row: Int, column: Int) {
        field[row - 1][column - 1].clear()
    }
    
    func clearAllCells() {
        for i in field {
            for j in i {
                j.clear()
            }
        }
    }
    
    func reset(row: Int, column: Int) {
        field[row - 1][column - 1].reset()
    }
    
    func resetAllCells() {
        for i in field {
            for j in i {
                j.reset()
            }
        }
    }
    
    func isFilled(row: Int, column: Int) -> Bool {
        return field[row - 1][column - 1].isFilled()
    }
    
    func allCellsFilled() -> Bool {
        for i in 0...fieldSize-1 {
            for j in 0...fieldSize-1 {
                if (!field[i][j].isFilled()) {
                    return false
                }
            }
        }
        return true
    }
    
    func numberOfFilledCells() -> Int{
        var filled: Int = 0
        for i in 1...fieldSize {
            for j in 1...fieldSize {
                if (isFilled(row: i, column: j)) {
                    filled += 1
                }
            }
        }
        return filled
    }
    
    func numberOfHiddenCells() -> Int{
        return numberOfCells() - numberOfFilledCells()
    }
    
    func get(row: Int, column: Int) -> Int{
        return field[row - 1][column - 1].get()
    }
    
    func set(number: Int, row: Int, column: Int) {
        field[row - 1][column - 1].set(number: number)
    }
    
    func hide(row: Int, column: Int) {
        field[row - 1][column - 1].hide()
    }
    
    func show(row: Int, column: Int) {
        field[row - 1][column - 1].show()
    }
    
    func tryNumber(number: Int, row: Int, column: Int) {
        field[row - 1][column - 1].tryNumber(number: number)
    }
    
    func numberHasBeenTried(number: Int, row: Int, column: Int) -> Bool {
        return field[row - 1][column - 1].isTried(number: number)
    }
    
    func numberOfTriedNumbers(row: Int, column: Int) -> Int {
        return field[row - 1][column - 1].numberOfTried()
    }
    
    func checkNumberBox(number: Int, row: Int, column: Int) -> Bool {
        var r = row
        var c = column
        if (r % blockSize == 0) {
            r -= blockSize - 1
        } else {
            r = (r / blockSize) * blockSize + 1
        }
        if (c % blockSize == 0) {
            c -= blockSize - 1
        } else {
            c = (c / blockSize) * blockSize + 1
        }
        for i in r...((r + blockSize) - 1) {
            for j in c...((c + blockSize) - 1) {
                if (field[i - 1][j - 1].isFilled() && (field[i - 1][j - 1].get() == number)) {
                    return false
                }
            }
        }
        return true
    }
    
    func checkNumberRow(number:Int, row:Int) -> Bool {
        for i in 0...fieldSize-1 {
            if (field[row - 1][i].isFilled() && field[row - 1][i].get() == number) {
                return false
            }
        }
        return true
    }
    
    func checkNumberColumn(number:Int, column:Int) -> Bool {
        for i in 0...fieldSize-1 {
            if (field[i][column - 1].isFilled() && field[i][column - 1].get() == number) {
                return false
            }
        }
        return true
    }
    
    func checkNumberField(number: Int, row: Int, column: Int) -> Bool{
        return (checkNumberBox(number: number, row: row, column: column)
            && checkNumberRow(number: number, row: row)
            && checkNumberColumn(number: number, column: column))
    }
    
    func numberOfPossibleVariants(row:Int, column:Int) -> Int {
        var result = 0
        for i in 1...fieldSize {
            if (checkNumberField(number: i, row: row, column: column)) {
                result += 1
            }
        }
        return result
    }
    
    func isCorrect() -> Bool{
        for i in 0...fieldSize-1 {
            for j in 0...fieldSize-1 {
                if (field[i][j].isFilled()) {
                    let value = field[i][j].get()
                    field[i][j].hide()
                    let correct:Bool = checkNumberField(number: value, row: i + 1, column: j + 1)
                    field[i][j].show()
                    if (!correct) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func nextCell(row: Int, column: Int) -> [Int] {
        var r = row
        var c = column
        if (c < fieldSize) {
            c += 1
        } else {
            c = 1
            r += 1
        }
        return [r,c]
    }
    
    func cellWithMinVariants() -> [Int] {
        var r = 1
        var c = 1
        var min = 9
        for i in 1...fieldSize {
            for j in 1...fieldSize {
                if (!field[i - 1][j - 1].isFilled()) {
                    if (numberOfPossibleVariants(row: i, column: j) < min) {
                        min = numberOfPossibleVariants(row: i, column: j)
                        r = i
                        c = j
                    }
                }
            }
        }
        return [r, c]
    }
    
    func getRandomIndex() -> Int {
        return Int(arc4random_uniform(10)) % fieldSize + 1
    }
    
}
