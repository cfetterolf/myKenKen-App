//
//  ChallengeViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/19/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit


class ChallengeViewController: UIViewController {

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
    
    var CHALLENGE_MODE = "Easy"
    
    @IBOutlet var popUpViewHint: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var timerView: UIView!
    @IBOutlet var stopwatchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdown = initCountdown
        self.navigationItem.title = selectedDiff
        let myBackButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        myBackButton.addTarget(self, action: "popToRoot:", for: UIControlEvents.touchUpInside)
        myBackButton.setTitle("Quit", for: UIControlState.normal)
        myBackButton.setTitleColor(UIColor.white, for: UIControlState.normal)
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
        showPopUp(time: <#T##String#>)
        
        //Generate field
        //generatePuzzle()
        
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
                if match == true {
                    timer.invalidate()
                    updateTimesArray(seconds: totalSeconds)
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
        self.generatePuzzle()
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
        if (sender.titleLabel?.text == "Value") {
            popUpViewHint.isHidden = true
            popUpView.isHidden = false
            tmpButton0?.backgroundColor = .clear
            tmpButton1?.backgroundColor = .clear
        } else {
            let hintText = (sender.titleLabel?.text!)!
            
            if hintButton % 2 == 0 {
                tmpButton0?.setTitle(hintText, for: .normal)
            } else {
                tmpButton1?.setTitle(hintText, for: .normal)
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
        }
        
        if countdown == 0 {
            timer.invalidate()
            stopwatchLabel.textColor = .white
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
        
        // Save top 10 in Array
        let i = 10
        while (timesArray.count > 10) {
            timesArray.remove(at: i)
        }
        
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
        for i in 0...45 {
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
        
        // Pick a board
        // Number in arc4random is how many cage pngs we have to choose from
        let randNum = Int(arc4random_uniform(7)) + 1
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
            //stopwatchLabel.backgroundColor = UIColor.green
        }
            // MEDIUM
        else if (avgDifficulty >= 1.3) && (avgDifficulty < 1.8) {
            //stopwatchLabel.backgroundColor = UIColor.blue
        }
            // HARD
        else { // > 1.86
            //stopwatchLabel.backgroundColor = UIColor.red
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
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[0][3]
                c = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label2.text = result
                
                // Set label4
                a = completedField[1][0]
                b = completedField[2][0]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label4.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[1][2]
                c = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label5.text = result
                
                // Set label10
                a = completedField[2][2]
                b = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label10.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label11.text = result
                
                // Set label12
                a = completedField[3][0]
                b = completedField[3][1]
                result = pickRandomOp(a: a, b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
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
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                totalCages += 1
                label2.text = String(a)
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][2]
                c = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label3.text = result
                
                // Set label4
                a = completedField[1][0]
                b = completedField[1][1]
                c = completedField[2][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label4.text = result
                
                // Set label9
                a = completedField[2][1]
                b = completedField[2][2]
                c = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label9.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label11.text = result
                
                // Set label12
                a = completedField[3][0]
                b = completedField[3][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
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
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[0][3]
                c = completedField[1][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                
                label2.text = result
                
                
                // Set label4
                a = completedField[1][0]
                b = completedField[1][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label4.text = result
                
                // Set label7
                a = completedField[1][3]
                b = completedField[2][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label7.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[2][1]
                c = completedField[3][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label8.text = result
                
                // Set label10
                label10.text = String(completedField[2][2])
                totalCages += 1
                
                // Set label13
                a = completedField[3][1]
                b = completedField[3][2]
                c = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
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
                totalCages += 1
                label0.text = result
                
                // Set label1
                a = completedField[0][1]
                b = completedField[0][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label1.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                c = completedField[2][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label5.text = result
                
                // Set label6
                a = completedField[1][2]
                totalCages += 1
                label6.text = String(a)
                
                // Set label8
                a = completedField[2][0]
                totalCages += 1
                label8.text = String(a)
                
                // Set label10
                a = completedField[2][2]
                b = completedField[3][2]
                c = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label10.text = result
                
                // Set label12
                a = completedField[3][0]
                b = completedField[3][1]
                result = pickRandomOp(a: a, b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label12.text = result
                
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
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[1][2]
                c = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label2.text = result
                
                // Set label3
                label3.text = String(completedField[0][3])
                totalCages += 1
                
                // Set label4
                a = completedField[1][0]
                b = completedField[2][0]
                c = completedField[3][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictTriple[result]!
                totalCages += 1
                label4.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label5.text = result
                
                // Set label10
                a = completedField[2][2]
                b = completedField[3][1]
                c = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label10.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
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
                totalCages += 1
                label0.text = result
                
                // Set label1
                a = completedField[0][1]
                b = completedField[0][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label1.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[1][2]
                c = completedField[2][2]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label5.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[2][1]
                c = completedField[3][0]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label8.text = result
                
                // Set label11
                a = completedField[2][3]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label11.text = result
                
                // Set label13
                a = completedField[3][1]
                b = completedField[3][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
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
                totalCages += 1
                label0.text = result
                
                // Set label2
                a = completedField[0][2]
                b = completedField[1][2]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label2.text = result
                
                // Set label3
                a = completedField[0][3]
                b = completedField[1][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label3.text = result
                
                // Set label5
                a = completedField[1][1]
                b = completedField[2][1]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label5.text = result
                
                // Set label8
                a = completedField[2][0]
                b = completedField[3][0]
                c = completedField[3][1]
                result = pickRandomOp(a: a,b: b, c: c)
                totalDifficulty += difficultyDictL[result]!
                totalCages += 1
                label8.text = result
                
                // Set label10
                a = completedField[2][2]
                b = completedField[2][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label10.text = result
                
                // Set label14
                a = completedField[3][2]
                b = completedField[3][3]
                result = pickRandomOp(a: a,b: b, c: -1)
                totalDifficulty += difficultyDictPair[result]!
                totalCages += 1
                label14.text = result
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
        bg1.clipsToBounds = true
        
        bg2.layer.cornerRadius = 12.0
        bg2.clipsToBounds = true
        
        bg3.layer.cornerRadius = 12.0
        bg3.clipsToBounds = true
        
        bg4.layer.cornerRadius = 12.0
        bg4.clipsToBounds = true
        
        bg5.layer.cornerRadius = 12.0
        bg5.clipsToBounds = true
        
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
        
        bg11.layer.cornerRadius = 12.0
        bg11.clipsToBounds = true
        
        bg12.layer.cornerRadius = 12.0
        bg12.clipsToBounds = true
        
        bg13.layer.cornerRadius = 12.0
        bg13.clipsToBounds = true
        
        bg14.layer.cornerRadius = 12.0
        bg14.clipsToBounds = true
        
        bg15.layer.cornerRadius = 12.0
        bg15.clipsToBounds = true
        
        bg16.layer.cornerRadius = 12.0
        bg16.clipsToBounds = true
        
        bg17.layer.cornerRadius = 12.0
        bg17.clipsToBounds = true
        
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
    

}
