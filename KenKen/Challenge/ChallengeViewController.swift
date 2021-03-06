//
//  ChallengeViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/19/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import AudioToolbox

protocol StartViewControllerDelegate: class {
    func didFinishTask(sender: StartViewController)
}

var diffIndex:Int = 0


class ChallengeViewController: UIViewController, Dimmable {

    // Init local variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    var currentDifficulty = ""
    var cageArray:[Cage] = []
    
    //var CHALLENGE_MODE = "Easy"
    
    @IBOutlet var popUpViewHint: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var timerView: UIView!
    @IBOutlet var stopwatchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdown = initCountdown
        self.navigationItem.title = selectedDiff
        let myBackButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        myBackButton.addTarget(self, action: #selector(ChallengeViewController.popToRoot(_:)), for: UIControlEvents.touchUpInside)
        myBackButton.setTitle("Quit", for: UIControlState.normal)
        myBackButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        
        self.view.clipsToBounds = true
        
        //Config Nav Bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        initBackgrounds()
        
        popUpView.isHidden = true
        popUpViewHint.isHidden = true
        
        //Intro PopOver
        performSegue(withIdentifier: "startChallenge", sender: self)
        currentDifficulty = currentChallenge.difficultyArray[currentChallenge.nextPuzzleIndex]
        performSG = false
        
    }
    
    @IBAction func popToRoot(_ sender: UIBarButtonItem) {
        self.displayAlert("Quit to Menu?", message:"You will lose all progress in current challenge.")
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        timer.invalidate()
        self.navigationController?.popViewController(animated: true)
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
                
                //Check if there are any repeats in rows or columns
                //If so, display error to user
                let inValArr = checkIfValueRepeated(field: currentField, x:i, y:j)
                for i in 0...3 {
                    for j in 0...3 {
                        let val = inValArr[i][j]
                        if val == 1 {
                            //Flash index bg red
                            let tag = (i*4) + j
                            flashRed(tag:tag)
                        }
                    }
                }
                
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
                
                if match == true || finish == true  {
                    let sec = currentChallenge.initCountdownArray[currentChallenge.nextPuzzleIndex]-countdown
                    currentChallenge.timeFinishedArray.append((sec))
                    updateTimesArray(seconds: sec)
                    scoreBoard.addTime(difficulty: currentDifficulty, seconds: sec)
        
                    
                    if currentChallenge.nextPuzzleIndex == 2 {
                        //FINSHED CHALLENGE!
                        timer.invalidate()
                        self.performSegue(withIdentifier: "challengeCompleted", sender: self)
                        self.navigationController?.setNavigationBarHidden(true, animated: true)
                        
                    } else {
                        timer.invalidate()
                        showPopUp(time: stopWatchString)
                        currentChallenge.nextPuzzleIndex += 1
                    }
                   
                }
                
            }
            popUpView.isHidden = true
            timerView.isHidden = false
        }
    }
    
    /*
     Checks if input value repeats in any other values in rows and columns.
     Returns new array of same size as currentField, with 1's where invalid repeats occur and
     0's everywhere else
     */
    func checkIfValueRepeated(field: [[Int]], x:Int, y: Int) -> [[Int]] {
        
        //Create invalidArray
        var invalidArray = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        
        //Check row
        let row:[Int] = field[x]
        for j in 0...row.count-1 {
            if row[j] == field[x][y] && j != y {
                invalidArray[x][j] = 1
            }
        }
        
        //Check column
        for i in 0...field.count-1 {
            if field[i][y] == field[x][y] && i != x {
                invalidArray[i][y] = 1
            }
        }
        
        return invalidArray
    }
    
    
    var tile = UIButton()
    
    //Takes as input a button tag.  Flashes that buttons bg red
    func flashRed(tag: Int) {
        let lightRed = UIColor(hue: 0.99, saturation: 0.28, brightness: 0.84, alpha: 0.5)
        
        if tag == 0 {
            firstButton.backgroundColor = UIColor(hue: 0.99, saturation: 0.28, brightness: 0.84, alpha: 0)
            
            //Animate Flash
            UIView.animate(withDuration: 0.4, animations: {
                self.firstButton.backgroundColor = lightRed
            })
            UIView.animate(withDuration: 0.2, delay: 1.0, options: [], animations: {
                self.firstButton.backgroundColor = .clear
            }, completion: nil)
            
            //Vibrate
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else {
            //Get the tile to flash
            tile = self.view.viewWithTag(tag) as! UIButton
            tile.layer.cornerRadius = 12.0
            tile.clipsToBounds = true
            tile.backgroundColor = UIColor(hue: 0.99, saturation: 0.28, brightness: 0.84, alpha: 0)
            
            //Animate Flash
            UIView.animate(withDuration: 0.4, animations: {
                self.tile.backgroundColor = lightRed
            })
            UIView.animate(withDuration: 0.2, delay: 1.0, options: [], animations: {
                self.tile.backgroundColor = .clear
            }, completion: nil)
            
            //Vibrate
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbFinishedID") as! FinishedViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = (self.parent?.view.frame)!
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    func showStart() {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbStartID") as! StartViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = (self.parent?.view.frame)!
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    func showFailed() {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbFailedID") as! FailedViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = (self.parent?.view.frame)!
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        self.clearTiles(self)
        self.clearLabels()
        firstPuzzle = false
        self.performSegue(withIdentifier: "startChallenge", sender: self)
        currentDifficulty = currentChallenge.difficultyArray[currentChallenge.nextPuzzleIndex]
        self.stopwatchLabel.text = "00:00"
        self.stopwatchLabel.textColor = .darkGray
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
        countdown = initCountdown
        formatCountdown()
        stopwatchLabel.text = stopWatchString
    }
    
    func result() {
        countdown -= 1
        //print(countdown)
        formatCountdown()
        
        stopwatchLabel.text = stopWatchString
        
        if countdown < 6 {
            stopwatchLabel.textColor = UIColor(hue: 0.0, saturation: 0.5, brightness: 1.0, alpha: 1.0)
        } else {
            stopwatchLabel.textColor = .darkGray
        }
        
        if countdown == 0 {
            timer.invalidate()
            stopwatchLabel.textColor = .darkGray
            showFailed()
        }
    }
    
    func formatCountdown() {
        minutes = countdown / 60
        seconds = countdown - (60*minutes)
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        stopWatchString = "\(minutesString):\(secondsString)"
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
        generatePuzzle()
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
    
    
    func startChallenge() {
        generatePuzzle()
        
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
        timer.invalidate()
        clearTimer()
        startTimer()
        setDifficultyBG()
        print(avgDifficulty)
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
        
        if currentDifficulty == "Easy" {
            if avgDifficulty > 1.3 {
                generatePuzzle()
            }
        } else if currentDifficulty == "Medium" {
            if (avgDifficulty < 1.3) || (avgDifficulty > 1.8) {
                generatePuzzle()
            }
        } else if currentDifficulty == "Hard" {
            if avgDifficulty < 1.8 {
                generatePuzzle()
            }
        }
        
        
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
        setBG(view: mainbg)
        setBG(view: bg1)
        setBG(view: bg2)
        setBG(view: bg3)
        setBG(view: bg4)
        setBG(view: bg5)
        setBG(view: bg7)
        setBG(view: bg8)
        setBG(view: bg10)
        setBG(view: bg11)
        setBG(view: bg12)
        setBG(view: bg13)
        setBG(view: bg14)
        setBG(view: bg15)
        setBG(view: bg16)
        setBG(view: bg17)
    }
    
    func setBG(view: UIView) {
        view.layer.cornerRadius = 12.0
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 3
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.alpha = 0.75
    }

    
    func clearLabels() {
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
    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Quit", style: UIAlertActionStyle.cancel, handler: { (action) in
            // Quit to Menu
            self.timer.invalidate()
            self.performSegue(withIdentifier: "unwindToMenu", sender: self)
            
        }))
        alert.addAction(UIAlertAction(title: "Resume", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "startChallenge" {
            if firstPuzzle == false {
                dim(direction: .In, alpha: dimLevel, speed: 0.36)
                let dest = segue.destination as! StartViewController
                dest.delegate = self
            } else {
                dim(direction: .In, alpha: dimLevel, speed: dimSpeed)
                currentChallenge.restart()
                let dest = segue.destination as! StartViewController
                dest.delegate = self
            }
        } else if segue.identifier == "challengeCompleted" {
            dim(direction: .In, alpha: dimLevel, speed: dimSpeed)
            //let dest = segue.destination as! StartViewController
            //dest.delegate = self
        }
        
    }
    
    @IBAction func tapSound(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1306)
    }
    
    @IBAction func unwindFromSecondary(segue: UIStoryboardSegue) {
        dim(direction: .Out, speed: dimSpeed)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    

}

extension ChallengeViewController: StartViewControllerDelegate {
    func didFinishTask(sender: StartViewController) {
        // do stuff like updating the UI
        self.startChallenge()
    }
}
