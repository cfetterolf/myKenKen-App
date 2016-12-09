//
//  ViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 10/30/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

// Init Global Variables
var allPossible = [[[Int]]]()
var field = KenKenField(blocks: 2)
var currentField = Array(repeating: Array(repeating: 0, count: 4), count: 4)
var completedField = Array(repeating: Array(repeating: 0, count: 4), count: 4)
var cageField = Array(repeating: Array(repeating: -1, count: 4), count: 4)
var finishTime = "00:00"
var totalDifficulty = 0
var totalCages = 0
var avgDifficulty:Float = 0.0
var puzzleDifficulty = "Easy"

let easyColor = UIColor(hue: 0.99, saturation: 0.31, brightness: 0.82, alpha: 1.0)

// Protocall used to call generatePuzzle() from outside of VC
protocol ParentProtocol : class
{
    func method()
}

/*
 Scaling used to determine difficulty:
 avg > 1.86 = hard
 1.86 > avg > 1.5 = medium
 avg < 1.5 = easy
*/
class ViewController: UIViewController {

    // Init local variables
    var buttonTag = 0
    var buttonText = ""
    var timer = Timer()
    var minutes: Int = 0
    var seconds: Int = 0
    var fractions: Int = 0
    var totalSeconds:Int = 0
    var hintButton = 0
    var closeHint = 0
    var stopWatchString: String = "00:00"
    
    var cageArray:[Cage] = []
    
    
    @IBOutlet var popUpViewHint: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var timerView: UIView!
    @IBOutlet var stopwatchLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Play"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.view.clipsToBounds = true
        
        //Config Nav Bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        initBackgrounds()
        
        popUpView.isHidden = true
        popUpViewHint.isHidden = true
        
        //Generate field
        generatePuzzle()
        
        NotificationCenter.default.addObserver(self, selector: Selector(("refreshList:")), name:NSNotification.Name(rawValue: "refresh"), object: nil)
        
    }
    
    // MARK: - User Input
    
    var tag1:Int = 0
    var tag2:Int = 0
    var tmpButton0: UIButton? = UIButton()
    var tmpButton1: UIButton? = UIButton()
    
    // Called when user selects the input for a selected tile
    // If Cancel, do nothing.  Else, display number and check if board is completed.
    @IBAction func popUpButton(_ sender: UIButton) {
        button.backgroundColor = .clear
        
        // Get tag buttons, set bgs to highlighted
        tag1 = button.tag*2+16
        tag2 = button.tag*2+17
        tmpButton0 = (self.view.viewWithTag(tag1) as? UIButton)!
        tmpButton1 = (self.view.viewWithTag(tag2) as? UIButton)!
        
        if (sender.titleLabel?.text == "Cancel") {
            popUpView.isHidden = true
            popUpViewHint.isHidden = true
            timerView.isHidden = false
            tmpButton0?.backgroundColor = .clear
            tmpButton1?.backgroundColor = .clear
        } else {
            buttonText = (sender.titleLabel?.text!)!
            button.setTitle(buttonText, for: UIControlState.normal)
            
            if button.tag < 16 {
                let i = button.tag / 4
                let j = button.tag % 4
                
                // Update current Field
                currentField[i][j] = Int(buttonText)!
                
                // Check if puzzle completed
                
                var match: Bool = false
                
                
                outerLoop: for i in 0...3{
                    for j in 0...3 {
                        if currentField[i][j] == completedField[i][j] {
                            match = true
                        } else {
                            match = false
                            break outerLoop
                        }
                    }
                }
                
 
                // Puzzle is completed
                let finish = checkIfCompleted()
                print(finish)
                
                if match == true || finish == true {
                    timer.invalidate()
                    updateTimesArray(seconds: totalSeconds)
                    scoreBoard.addTime(difficulty: puzzleDifficulty, seconds: totalSeconds)
                    showPopUp(time: stopWatchString)
                }
 
                
            }
 
            popUpView.isHidden = true
            timerView.isHidden = false
        }
    }
    
    // Called when user taps on tile.  Sets up above function to recieve user input.
    @IBAction func buttonPressed(_ sender: UIButton) {
        popUpView.isHidden = false
        timerView.isHidden = true
        popUpViewHint.isHidden = true
        tmpButton0?.backgroundColor = .clear
        tmpButton1?.backgroundColor = .clear
        
        // Reset index in array
        sender.setTitle(nil, for: .normal)
        if sender.tag < 16 {
            let i = sender.tag / 4
            let j = sender.tag % 4
            currentField[i][j] = 0
        }
        
        //clear button bgs
        for i in 0...15 {
            let tmpButton = self.view.viewWithTag(i) as? UIButton
            tmpButton?.backgroundColor = .clear
        }
        firstButton.backgroundColor = .clear
        
        // Highlight button bg
        sender.layer.cornerRadius = 12.0
        sender.clipsToBounds = true
        sender.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        
        buttonTag = sender.tag
        button = sender
        
    }
    
    func checkIfCompleted() -> Bool {
        
        var cageValueArray:[Int:Int] = [0:0,1:0,2:0,3:0,4:0,5:0,6:0,7:0,8:0]
        
        // Fill cages with values
        for i in 0...3 {
            for j in 0...3 {
                
                let cageValue = cageField[i][j]
                let index = cageValueArray[cageValue]
                let cageItem = cageArray[cageValue]
                
                if currentField[i][j] != 0 {
                    cageItem.valuesInCage[index!] = currentField[i][j]
                } else {
                    cageItem.valuesInCage[index!] = -100
                }
                
                cageValueArray[cageValue] = index!+1
            }
        }
        
        print("Filled vales")
        
        // Check if cages will accept
        for cage in cageArray {
            if cage.cageWillAccept() == false {
                print("didn't follow rules")
                return false
            }
        }
        
        // Make sure there are no reapeats in rows or columns
        if latinSquare(array: currentField) == false {
            return false
        } else {
            return true
        }
    }
    
    func latinSquare(array: [[Int]]) -> Bool {
        for i in 0...array.count-1 {
            // check for duplicates in each row
            if(duplicates(array: array[i])) {
                return false
            }
    
            // create a column array
            var column = [Int](repeating: 0, count: array[i].count)
            for j in 0...array.count-1 {
                column[j] = array[j][i]
            }
    
            // check for duplicates in each column
            if(duplicates(array: column)) {
                return false
            }
        }
        return true
    }
    
    func duplicates(array: [Int]) -> Bool {
        for i in 0...array.count-1 {
            for j in 0...array.count-1 {
                if (i != j && array[i] == array[j]) {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Finished View
    
    func showPopUp(time: String) {
        finishTime = time
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.delegate = self
        popOverVC.view.frame = (self.parent?.view.frame)!
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    
    // MARK: - Note (Hint) View
    
    
    
    @IBAction func hintPressed(_ sender: UIButton) {
        popUpViewHint.isHidden = false
        popUpView.isHidden = true
        
        // Get tag buttons, set bgs to highlighted
        tag1 = button.tag*2+16
        tag2 = button.tag*2+17
        tmpButton0 = (self.view.viewWithTag(tag1) as? UIButton)!
        tmpButton1 = (self.view.viewWithTag(tag2) as? UIButton)!
        tmpButton0?.layer.cornerRadius = 2.0
        tmpButton1?.layer.cornerRadius = 2.0
        if hintButton % 2 == 0 {
            tmpButton0?.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
        } else {
            tmpButton1?.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
        }

    }
    
    @IBAction func hintSet(_ sender: UIButton) {
        let hintText = (sender.titleLabel?.text!)!
        
        if hintButton % 2 == 0 {
            if hintText == "Delete" {
                tmpButton0?.setTitle(nil, for: .normal)
            } else {
                tmpButton0?.setTitle(hintText, for: .normal)
            }
        } else {
            if hintText == "Delete" {
                tmpButton1?.setTitle(nil, for: .normal)
            }else {
                tmpButton1?.setTitle(hintText, for: .normal)
            }
        }
        hintButton += 1
        
        if hintButton % 2 == 0 {
            tmpButton0?.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
            tmpButton1?.backgroundColor = .clear
        } else {
            tmpButton1?.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
            tmpButton0?.backgroundColor = .clear
        }
        
        
        if closeHint == 1 {
            button.backgroundColor = .clear
            tmpButton0?.backgroundColor = .clear
            tmpButton1?.backgroundColor = .clear
            popUpView.isHidden = true
            popUpViewHint.isHidden = true
            timerView.isHidden = false
            closeHint = 0
        } else {
            closeHint += 1
        }
    }
    
    
    
    
    
    // MARK: - Timer Settings
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.result), userInfo: nil, repeats: true)
    }
    
    func clearTimer() {
        totalSeconds = 0
        minutes = 0
        seconds = 0
        fractions = 0
        stopwatchLabel.text = "00:00"
    }
    
    func result() {
        seconds += 1
        totalSeconds += 1
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        stopWatchString = "\(minutesString):\(secondsString)"
        
        stopwatchLabel.text = stopWatchString
    }
    
    func updateTimesArray(seconds: Int) {
        timesArray.append(seconds)
        timesArray.sort()
        
        // Save array
        let defaults = UserDefaults.standard
        defaults.set(timesArray, forKey: "timesArray")
        
    }
    
    
    
    
    
    // MARK: - Format Board
    
    @IBOutlet var firstButton: UIButton!
    @IBOutlet var button: UIButton!
    @IBOutlet var cageView: UIImageView!
    
    @IBAction func generateButton(_ sender: Any) {
        if boardIsEmpty() {
            generatePuzzle()
        } else {
            self.displayAlert("Generate a New Puzzle?", message: "You will lose all progress on current puzzle")
        }
    }
    
    func boardIsEmpty() -> Bool {
        for array in currentField {
            for element in array {
                if element != 0 {
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func clearTiles(_ sender: Any) {
        
        //clear buttons
        for i in 0...47 {
            let tmpButton = self.view.viewWithTag(i) as? UIButton
            tmpButton?.setTitle(nil, for: .normal)
        }
        firstButton.setTitle(nil, for: .normal)
        //clear progress Array
        currentField = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        
    }
    
    // Generates a random field with a random board
    func generatePuzzle() {
        // Reset Field
        field = KenKenField(blocks: 2)
        // Generate new field
        generateFullField(row: 1, column: 1)
        
        clearTiles(self)
        
        for i in 0...3 {
            for j in 0...3 {
                completedField[i][j] = field.field[i][j].get()
            }
        }
        currentField = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        cageField = Array(repeating: Array(repeating: -1, count: 4), count: 4)
        cageArray = []
        
        // Pick a board
        // Number in arc4random is how many cage pngs we have to choose from
        let randNum = Int(arc4random_uniform(10)) + 1
        let cageName = "grid\(randNum).png"
        cageView.image = UIImage(named: cageName)
        setCageInfo(cageName: cageName)
        //print(cageArray)
        //print(cageField)
        timer.invalidate()
        clearTimer()
        startTimer()
        setDifficultyBG()
        //print(avgDifficulty)
    }
    
    // Generates a random field with a given board
    func generatePuzzle(cageName: String) {
        // Reset Field
        field = KenKenField(blocks: 2)
        // Generate new field
        generateFullField(row: 1, column: 1)
        
        clearTiles(self)
        
        for i in 0...3 {
            for j in 0...3 {
                completedField[i][j] = field.field[i][j].get()
            }
        }
        currentField = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        cageField = Array(repeating: Array(repeating: -1, count: 4), count: 4)
        cageArray = []
        
        cageView.image = UIImage(named: cageName)
        setCageInfo(cageName: cageName)
        
        timer.invalidate()
        clearTimer()
        startTimer()
        setDifficultyBG()
        print(avgDifficulty)
    }
    
    func setDifficultyBG() {
        // EASY
        if avgDifficulty < 1.3 {
            bg10.backgroundColor = easyGreen
            puzzleDifficulty = "Easy"
        }
        // MEDIUM
        else if (avgDifficulty >= 1.3) && (avgDifficulty < 1.8) {
            bg10.backgroundColor = mediumBlue
            puzzleDifficulty = "Medium"
        }
        // HARD
        else { // > 1.86
            bg10.backgroundColor = hardRed
            puzzleDifficulty = "Hard"
        }
    }
    
    // Sets random cage info for a given cagename
    private func setCageInfo(cageName: String) {
        
        // Clear all labels
        label0.text = ""
        label1.text = ""
        label2.text = ""
        label3.text = ""
        label4.text = ""
        label5.text = ""
        label6.text = ""
        label7.text = ""
        label8.text = ""
        label9.text = ""
        label10.text = ""
        label11.text = ""
        label12.text = ""
        label13.text = ""
        label14.text = ""
        label15.text = ""
        
        totalDifficulty = 0
        totalCages = 0
        
        if cageName == "grid1.png" {
            
            //Check if bad
            
            if (completedField[2][2] == completedField[3][3]) && (completedField[2][3] == completedField[3][2]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][0] == completedField[3][1]) && (completedField[0][1] == completedField[3][0]) {
                generatePuzzle(cageName: cageName)
            }
                
            else {
                
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[0][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[0][1] = totalCages
                totalCages += 1
                cageArray.append(Cage(size: 2, code: result))
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[0][3]
                c = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                cageField[0][2] = 1
                cageField[0][3] = 1
                cageField[1][3] = 1
                cageArray.append(Cage(size: 3, code: result))
                label2.text = result
                
                // Set label4
                a = completedField[1][0]
                b = completedField[2][0]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                cageField[1][0] = 2
                cageField[2][0] = 2
                cageArray.append(Cage(size: 2, code: result))
                label4.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[1][2]
                c = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                cageField[1][1] = 3
                cageField[1][2] = 3
                cageField[2][1] = 3
                cageArray.append(Cage(size: 3, code: result))
                label5.text = result
                
                // Set label10
                a = completedField[2][2]
                b = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                cageField[2][2] = 4
                cageField[3][2] = 4
                cageArray.append(Cage(size: 2, code: result))
                label10.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                cageField[2][3] = 5
                cageField[3][3] = 5
                cageArray.append(Cage(size: 2, code: result))
                label11.text = result
                
                // Set label12
                a = completedField[3][0]
                b = completedField[3][1]
                result = pickRandomOp(a: a, b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                cageField[3][0] = 6
                cageField[3][1] = 6
                cageArray.append(Cage(size: 2, code: result))
                label12.text = result
                
            }

            
        } else if  cageName == "grid5.png" {
            
            //Check if bad
            
            if (completedField[1][0] == completedField[2][1]) && (completedField[1][1] == completedField[2][0]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[1][0] == completedField[3][1]) && (completedField[1][1] == completedField[3][0]) {
                generatePuzzle(cageName: cageName)
            }
            
            else {
                
                
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[0][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[0][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                cageField[0][2] = totalCages
                cageArray.append(Cage(size: 1, code: String(a)))
                totalCages += 1
                label2.text = String(a)
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][2]
                c = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[0][3] = totalCages
                cageField[1][2] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label4
                a = completedField[1][0]
                b = completedField[1][1]
                c = completedField[2][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[1][0] = totalCages
                cageField[1][1] = totalCages
                cageField[2][0] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label4.text = result
                
                // Set label9
                a = completedField[2][1]
                b = completedField[2][2]
                c = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][1] = totalCages
                cageField[2][2] = totalCages
                cageField[3][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label9.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][3] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label11.text = result
                
                // Set label12
                a = completedField[3][0]
                b = completedField[3][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[3][0] = totalCages
                cageField[3][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label12.text = result
            }
            
        } else if cageName == "grid3.png" {
            //Check if bad
            
            if (completedField[0][0] == completedField[1][1]) && (completedField[0][1] == completedField[1][0]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][0] == completedField[2][1]) && (completedField[0][1] == completedField[2][0]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][2] == completedField[3][3]) && (completedField[0][3] == completedField[3][2]) {
                generatePuzzle(cageName: cageName)
            }
                
            else {
                
                
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[0][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[0][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[0][3]
                c = completedField[1][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[0][2] = totalCages
                cageField[0][3] = totalCages
                cageField[1][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                
                label2.text = result

                
                // Set label4
                a = completedField[1][0]
                b = completedField[1][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[1][0] = totalCages
                cageField[1][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label4.text = result
                
                // Set label7
                a = completedField[1][3]
                b = completedField[2][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[1][3] = totalCages
                cageField[2][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label7.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[2][1]
                c = completedField[3][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][0] = totalCages
                cageField[2][1] = totalCages
                cageField[3][0] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label8.text = result
                
                // Set label10
                cageField[2][2] = totalCages
                cageArray.append(Cage(size: 1, code: String(completedField[2][2])))
                label10.text = String(completedField[2][2])
                totalCages += 1
                
                // Set label13
                a = completedField[3][1]
                b = completedField[3][2]
                c = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
                cageField[3][1] = totalCages
                cageField[3][2] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label13.text = result
            }

        } else if cageName == "grid4.png" {
            
            //Check if bad
            
            if (completedField[0][0] == completedField[1][3]) && (completedField[1][0] == completedField[0][3]) {
                generatePuzzle(cageName: cageName)
            }
                
            else {
                
                
                
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[1][0]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[1][0] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label0.text = result
                
                // Set label1
                a = completedField[0][1]
                b = completedField[0][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][1] = totalCages
                cageField[0][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label1.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                c = completedField[2][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
                cageField[0][3] = totalCages
                cageField[1][3] = totalCages
                cageField[2][3] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[1][1] = totalCages
                cageField[2][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label5.text = result
                
                // Set label6
                a = completedField[1][2]
                cageField[1][2] = totalCages
                cageArray.append(Cage(size: 1, code: String(a)))
                totalCages += 1
                label6.text = String(a)
                
                // Set label8
                a = completedField[2][0]
                cageField[2][0] = totalCages
                cageArray.append(Cage(size: 1, code: String(a)))
                totalCages += 1
                label8.text = String(a)
                
                // Set label10
                a = completedField[2][2]
                b = completedField[3][2]
                c = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][2] = totalCages
                cageField[3][2] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label10.text = result
                
                // Set label12
                a = completedField[3][0]
                b = completedField[3][1]
                result = pickRandomOp(a: a, b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[3][0] = totalCages
                cageField[3][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label12.text = result
                
                totalCages += 1
                
            }

            
        } else if cageName == "grid2.png" {
            
            //Check if bad
            
            if (completedField[2][1] == completedField[3][2]) && (completedField[2][2] == completedField[3][1]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[1][0] == completedField[2][1]) && (completedField[1][1] == completedField[2][0]) {
                generatePuzzle(cageName: cageName)

            } else if (completedField[2][0] == completedField[3][2]) && (completedField[2][2] == completedField[3][0]) {
                generatePuzzle(cageName: cageName)
            }

            
            else {
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[0][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[0][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[1][2]
                c = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[0][2] = totalCages
                cageField[1][2] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label2.text = result
                
                // Set label3
                a = completedField[0][3]
                cageField[0][3] = totalCages
                cageArray.append(Cage(size: 1, code: String(a)))
                totalCages += 1
                label3.text = String(a)
                
                // Set label4
                a = completedField[1][0]
                b = completedField[2][0]
                c = completedField[3][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
                cageField[1][0] = totalCages
                cageField[2][0] = totalCages
                cageField[3][0] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label4.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[1][1] = totalCages
                cageField[2][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label5.text = result
                
                // Set label10
                a = completedField[2][2]
                b = completedField[3][1]
                c = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][2] = totalCages
                cageField[3][1] = totalCages
                cageField[3][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label10.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][3] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label11.text = result
            }

        } else if cageName == "grid6.png" {
            
            //Check if bad
            
            if (completedField[0][1] == completedField[1][2]) && (completedField[0][2] == completedField[1][1]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[2][0] == completedField[3][3]) && (completedField[3][0] == completedField[2][3]) {
                generatePuzzle(cageName: cageName)
                
            } else if (completedField[0][1] == completedField[3][2]) && (completedField[0][2] == completedField[3][1]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][1] == completedField[2][2]) && (completedField[0][2] == completedField[2][1]) {
                generatePuzzle(cageName: cageName)
            }
                
                
            else {
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[1][0]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[1][0] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label0.text = result
                
                // Set label1
                a = completedField[0][1]
                b = completedField[0][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][1] = totalCages
                cageField[0][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label1.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][3] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[1][2]
                c = completedField[2][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[1][1] = totalCages
                cageField[1][2] = totalCages
                cageField[2][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label5.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[2][1]
                c = completedField[3][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][0] = totalCages
                cageField[2][1] = totalCages
                cageField[3][0] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label8.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][3] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label11.text = result
                
                // Set label13
                a = completedField[3][1]
                b = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[3][1] = totalCages
                cageField[3][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label13.text = result
            }

            
            
        } else if cageName == "grid7.png" {
            
            //Check if bad
            
            if (completedField[0][0] == completedField[3][1]) && (completedField[0][1] == completedField[3][0]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][0] == completedField[1][2]) && (completedField[1][0] == completedField[0][2]) {
                generatePuzzle(cageName: cageName)
                
            } else if (completedField[0][0] == completedField[1][3]) && (completedField[1][0] == completedField[0][3]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[2][2] == completedField[3][3]) && (completedField[2][3] == completedField[3][2]) {
                generatePuzzle(cageName: cageName)
            }
                
                
            else {
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[0][1]
                c = completedField[1][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[0][0] = totalCages
                cageField[0][1] = totalCages
                cageField[1][0] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[1][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][2] = totalCages
                cageField[1][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label2.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][3] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[1][1] = totalCages
                cageField[2][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label5.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[3][0]
                c = completedField[3][1]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][0] = totalCages
                cageField[3][0] = totalCages
                cageField[3][1] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label8.text = result
                
                // Set label10
                a = completedField[2][2]
                b = completedField[2][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][2] = totalCages
                cageField[2][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label10.text = result
                
                // Set label14
                a = completedField[3][2]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[3][2] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label14.text = result
            }
            
            
            
        } else if cageName == "grid8.png" {
            
            //Check if bad
            
            if (completedField[0][0] == completedField[1][2]) && (completedField[1][0] == completedField[0][2]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][0] == completedField[1][3]) && (completedField[1][0] == completedField[0][3]) {
                generatePuzzle(cageName: cageName)
                
            } else if (completedField[2][0] == completedField[1][3]) && (completedField[3][0] == completedField[2][3]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[2][1] == completedField[3][2]) && (completedField[2][2] == completedField[3][1]) {
                generatePuzzle(cageName: cageName)
            }
                
                
            else {
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[1][0]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[1][0] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label0.text = result
                
                
                // Set label1
                a = completedField[0][1]
                cageField[0][1] = totalCages
                cageArray.append(Cage(size: 1, code: String(a)))
                totalCages += 1
                label1.text = String(a)
                
                // Set label2
                a = completedField[0][2]
                b = completedField[1][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][2] = totalCages
                cageField[1][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label2.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][3] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[2][1]
                c = completedField[2][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[1][1] = totalCages
                cageField[2][1] = totalCages
                cageField[2][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label5.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[3][0]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][0] = totalCages
                cageField[3][0] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label8.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][3] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label11.text = result
                
                // Set label13
                a = completedField[3][1]
                b = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[3][1] = totalCages
                cageField[3][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label13.text = result
            }
            
            
            
        } else if cageName == "grid9.png" {
            
            //Check if bad
            
            if (completedField[0][0] == completedField[1][3]) && (completedField[1][0] == completedField[0][3]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][1] == completedField[1][2]) && (completedField[0][2] == completedField[1][1]) {
                generatePuzzle(cageName: cageName)
                
            } else if (completedField[0][1] == completedField[3][2]) && (completedField[0][2] == completedField[3][1]) {
                generatePuzzle(cageName: cageName)
            }
                
                
            else {
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[1][0]
                c = completedField[2][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
                cageField[0][0] = totalCages
                cageField[1][0] = totalCages
                cageField[2][0] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label0.text = result
                
                
                // Set label1
                a = completedField[0][1]
                b = completedField[0][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][1] = totalCages
                cageField[0][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label1.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][3] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[1][2]
                c = completedField[2][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[1][1] = totalCages
                cageField[1][2] = totalCages
                cageField[2][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label5.text = result
                
                // Set label9
                a = completedField[2][1]
                b = completedField[3][1]
                c = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][1] = totalCages
                cageField[3][1] = totalCages
                cageField[3][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label9.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][3] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label11.text = result
                
                // Set label12
                a = completedField[3][0]
                cageField[3][0] = totalCages
                cageArray.append(Cage(size: 1, code: String(a)))
                totalCages += 1
                label12.text = String(a)
                
                totalCages -= 2
            }
            
            
            
        } else if cageName == "grid10.png" {
            
            //Check if bad
            
            if (completedField[0][0] == completedField[1][3]) && (completedField[1][0] == completedField[0][3]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][1] == completedField[1][2]) && (completedField[0][2] == completedField[1][1]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[0][1] == completedField[2][2]) && (completedField[0][2] == completedField[2][1]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[2][0] == completedField[3][1]) && (completedField[2][1] == completedField[3][0]) {
                generatePuzzle(cageName: cageName)
            } else if (completedField[1][1] == completedField[2][2]) && (completedField[1][2] == completedField[2][1]) {
                generatePuzzle(cageName: cageName)
            }
                
                
            else {
                var a: Int
                var b: Int
                var c: Int
                var result: String
                
                // Set label0
                a = completedField[0][0]
                b = completedField[1][0]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][0] = totalCages
                cageField[1][0] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label0.text = result
                
                // Set label1
                a = completedField[0][1]
                b = completedField[0][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][1] = totalCages
                cageField[0][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label1.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[0][3] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[1][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[1][1] = totalCages
                cageField[1][2] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label5.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[2][1]
                c = completedField[2][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
                cageField[2][0] = totalCages
                cageField[2][1] = totalCages
                cageField[2][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label8.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][2]
                c = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                cageField[2][3] = totalCages
                cageField[3][2] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label11.text = result
                
                // Set label12
                a = completedField[3][0]
                b = completedField[3][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                cageField[3][0] = totalCages
                cageField[3][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label12.text = result
                
            }
            
            
            
        }

        
        avgDifficulty = Float(totalDifficulty)/Float(totalCages)
        
    }
    
    func pickRandomOp(a: Int, b: Int, c: Int) -> String {
        
        var resultsArray = [String]()
        
        if c == -1 {
            let multResult = "\(a*b)x"
            resultsArray.append(multResult)
            
            let addResult = "\(a+b)+"
            resultsArray.append(addResult)
            
            if (a*b == 2 || a*b == 8) {
                if a > b {
                    let divResult = "\(a/b)÷"
                    resultsArray.append(divResult)
                } else {
                    let divResult = "\(b/a)÷"
                    resultsArray.append(divResult)
                }
            }
            
            let subResult = "\(abs(a-b))-"
            resultsArray.append(subResult)
            
            let randNum = Int(arc4random_uniform(UInt32(resultsArray.count)))
            
            let characters = Array(resultsArray[randNum].characters)
            var strArr:[AnyObject] = [AnyObject]()
            strArr.append(characters.last as AnyObject)
            var newStr = ""
            for i in 0...characters.count-2 {
                newStr += String(characters[i])
            }
            strArr.append(Int(newStr) as AnyObject)
            return resultsArray[randNum]
            
        } else {
            let multResult = "\(a*b*c)x"
            resultsArray.append(multResult)
            
            let addResult = "\(a+b+c)+"
            resultsArray.append(addResult)
            
            let randNum = Int(arc4random_uniform(UInt32(resultsArray.count)))
            let characters = Array(resultsArray[randNum].characters)
            var strArr:[AnyObject] = [AnyObject]()
            strArr.append(characters.last as AnyObject)
            var newStr = ""
            for i in 0...characters.count-2 {
                newStr += String(characters[i])
            }
            strArr.append(Int(newStr) as AnyObject)

            return resultsArray[randNum]
        }
    }
    
    
    // MARK: - Generate Field
    
    // Generates random Latin Square, rows = 4, columns = 4.  Assigns to global array completedField.
    private func generateFullField(row:Int, column:Int) {
        if (!field.isFilled(row: field.fieldSize, column: field.fieldSize)) {
            while (field.numberOfTriedNumbers(row: row, column: column) < field.variantsPerCell()) {
                var candidate = 0
                repeat {
                    candidate = field.getRandomIndex()
                } while (field.numberHasBeenTried(number: candidate, row: row, column: column))
                if (field.checkNumberField(number: candidate, row: row, column: column)) {
                    field.set(number: candidate, row: row, column: column)
                    var nextCell:[Int] = field.nextCell(row: row, column: column)
                    if (nextCell[0] <= field.fieldSize
                        && nextCell[1] <= field.fieldSize) {
                        generateFullField(row: nextCell[0], column: nextCell[1])
                    }
                } else {
                    field.tryNumber(number: candidate, row: row, column: column)
                }
            }
            if (!field.isFilled(row: field.fieldSize, column: field.fieldSize)) {
                field.reset(row: row, column: column)
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Labels and backgrounds
    
    func initBackgrounds() {
        mainbg.layer.cornerRadius = 12.0
        mainbg.layer.shadowColor = UIColor.black.cgColor
        mainbg.layer.shadowOpacity = 0.4
        mainbg.layer.shadowRadius = 3
        mainbg.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg1.layer.cornerRadius = 12.0
        bg1.layer.shadowColor = UIColor.black.cgColor
        bg1.layer.shadowOpacity = 0.4
        bg1.layer.shadowRadius = 3
        bg1.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg2.layer.cornerRadius = 12.0
        bg2.layer.shadowColor = UIColor.black.cgColor
        bg2.layer.shadowOpacity = 0.4
        bg2.layer.shadowRadius = 3
        bg2.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg3.layer.cornerRadius = 12.0
        bg3.layer.shadowColor = UIColor.black.cgColor
        bg3.layer.shadowOpacity = 0.4
        bg3.layer.shadowRadius = 3
        bg3.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg4.layer.cornerRadius = 12.0
        bg4.layer.shadowColor = UIColor.black.cgColor
        bg4.layer.shadowOpacity = 0.4
        bg4.layer.shadowRadius = 3
        bg4.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg5.layer.cornerRadius = 12.0
        bg5.layer.shadowColor = UIColor.black.cgColor
        bg5.layer.shadowOpacity = 0.4
        bg5.layer.shadowRadius = 3
        bg5.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg6.layer.cornerRadius = 12.0
        bg6.layer.shadowColor = UIColor.black.cgColor
        bg6.layer.shadowOpacity = 0.4
        bg6.layer.shadowRadius = 3
        bg6.layer.shadowOffset = CGSize(width: 3, height: 3)

        
        bg7.layer.cornerRadius = 12.0
        bg7.layer.shadowColor = UIColor.black.cgColor
        bg7.layer.shadowOpacity = 0.4
        bg7.layer.shadowRadius = 3
        bg7.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg8.layer.cornerRadius = 12.0
        bg8.layer.shadowColor = UIColor.black.cgColor
        bg8.layer.shadowOpacity = 0.4
        bg8.layer.shadowRadius = 3
        bg8.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg10.layer.cornerRadius = 12.0
        bg10.layer.shadowColor = UIColor.black.cgColor
        bg10.layer.shadowOpacity = 0.4
        bg10.layer.shadowRadius = 3
        bg10.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg11.layer.cornerRadius = 12.0
        bg11.layer.shadowColor = UIColor.black.cgColor
        bg11.layer.shadowOpacity = 0.4
        bg11.layer.shadowRadius = 3
        bg11.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg12.layer.cornerRadius = 12.0
        bg12.layer.shadowColor = UIColor.black.cgColor
        bg12.layer.shadowOpacity = 0.4
        bg12.layer.shadowRadius = 3
        bg12.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg13.layer.cornerRadius = 12.0
        bg13.layer.shadowColor = UIColor.black.cgColor
        bg13.layer.shadowOpacity = 0.4
        bg13.layer.shadowRadius = 3
        bg13.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg14.layer.cornerRadius = 12.0
        bg14.layer.shadowColor = UIColor.black.cgColor
        bg14.layer.shadowOpacity = 0.4
        bg14.layer.shadowRadius = 3
        bg14.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg15.layer.cornerRadius = 12.0
        bg15.layer.shadowColor = UIColor.black.cgColor
        bg15.layer.shadowOpacity = 0.4
        bg15.layer.shadowRadius = 3
        bg15.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg16.layer.cornerRadius = 12.0
        bg16.layer.shadowColor = UIColor.black.cgColor
        bg16.layer.shadowOpacity = 0.4
        bg16.layer.shadowRadius = 3
        bg16.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        bg17.layer.cornerRadius = 12.0
        bg17.layer.shadowColor = UIColor.black.cgColor
        bg17.layer.shadowOpacity = 0.4
        bg17.layer.shadowRadius = 3
        bg17.layer.shadowOffset = CGSize(width: 3, height: 3)
        
    }
    
    @IBOutlet var label0: UILabel!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    @IBOutlet var label5: UILabel!
    @IBOutlet var label6: UILabel!
    @IBOutlet var label7: UILabel!
    @IBOutlet var label8: UILabel!
    @IBOutlet var label9: UILabel!
    @IBOutlet var label10: UILabel!
    @IBOutlet var label11: UILabel!
    @IBOutlet var label12: UILabel!
    @IBOutlet var label13: UILabel!
    @IBOutlet var label14: UILabel!
    @IBOutlet var label15: UILabel!
    
    @IBOutlet var bg1: UIImageView!
    @IBOutlet var bg2: UIImageView!
    @IBOutlet var bg3: UIImageView!
    @IBOutlet var bg4: UIImageView!
    @IBOutlet var bg5: UIImageView!
    @IBOutlet var bg6: UIImageView!
    @IBOutlet var bg7: UIView!
    @IBOutlet var bg8: UIImageView!
    @IBOutlet var mainbg: UIImageView!
    @IBOutlet var bg10: UIImageView!
    @IBOutlet var bg11: UIImageView!
    @IBOutlet var bg12: UIImageView!
    @IBOutlet var bg13: UIImageView!
    @IBOutlet var bg14: UIImageView!
    @IBOutlet var bg15: UIImageView!
    @IBOutlet var bg16: UIImageView!
    @IBOutlet var bg17: UIImageView!
    
    
    // Alert Function
    // Alert Function
    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "New Puzzle", style: UIAlertActionStyle.default, handler: { (action) in
            // Quit to Menu
            self.generatePuzzle()
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
}

extension ViewController : ParentProtocol {
    func method() {
        self.generatePuzzle()
    }
}

