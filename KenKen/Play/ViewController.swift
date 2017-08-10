//
//  ViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 10/30/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import AudioToolbox
import Firebase
import GoogleMobileAds

//MARK: - Init Global Variables

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
var tutorialOver = true



//MARK: - Protocol Methods

// Protocall used to call generatePuzzle() from outside of VC
protocol ParentProtocol : class
{
    func method()
    func resume()
}

/*
 Main ViewController class for the Play section.
 Handles generating new puzzles, checking entries, and keeping track of finish times.
*/
class ViewController: UIViewController, GADInterstitialDelegate {

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
    var cageArray:[Cage] = []
    var interstitial: GADInterstitial!
    @IBOutlet var popUpViewHint: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var timerView: UIView!
    @IBOutlet var stopwatchLabel: UILabel!
    

    //Set Nav Bar title back to "Play" when load view
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Play"
        interstitial = createAndLoadInterstitial()
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        tutorialOver = true
        print("UNWIND")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // TEST AD FUNCTIONALITY
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
//        let request = GADRequest()
//        interstitial.load(request)
        
        // END AD TEST
        
        self.view.clipsToBounds = true
        
        //Config Nav Bar
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationController?.navigationBar.topItem?.title = ""
        //self.navigationController?.navigationBar.alpha = 0.4
        
        //Set corner radius of all shapes
        initBackgrounds()
        
        //Configure Timer/Generate Puzzle views
        popUpView.isHidden = true
        popUpViewHint.isHidden = true
        
        
        if (playFirst == true) {
            generateFirstPuzzle()
            greyOut()
        } else {
            generatePuzzle()
        }
        
        NotificationCenter.default.addObserver(self, selector: Selector(("refreshList:")), name:NSNotification.Name(rawValue: "refresh"), object: nil)
        
    }
    
    // MARK: - Interstitial
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3560434471541225/8762103197")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        generatePuzzle()
    }
    
    
    
    // MARK : - First Puzzle Tutorial
    
    var firstTutProgress = true
    var firstSlide = true
    var progressCount = 0;
    var tutTitleArr = ["Welcome to Fours!", "Starter Tiles","Easy Cages", "Great Job!","Completing the Cage","Nice Work!","More Logic", "Awesome!","Great Work!", "Almost There...","Fantastic!"]
    
    var tutDescArr = ["Let's use this easy puzzle to learn Fours.  A green border indicates easy, blue means medium, and red is hard.  Keep this in mind when generating puzzles!",
                      "Let's solve this one together.  If the puzzle you generate has a 'starter' tile, like the highlighted one above, always begin by filling it in with the number in the upper left, or the 'target' number.  In this case, tap the tile and select '2.'",
                      "We can use some basic logic to figure out another tile.  Look at the '4x' cage: what two different numbers, when multiplied, equal 4?  Now that  we know 3 of the 4 numbers in the top row, we can fill in the highlighted tile with the remaining number.  Don't fill in the 1 or 4 yet - we don't know which tile holds which!",
                      "That wasn't too hard!  Now look at the '2x' cage in the far right column, and use the same logic to figure out what number should fill the highlighted tile.",
                      "Now that we know 2 of the 3 numbers in our '8+' cage, we can use basic arithmetic to figure out the third: 3 + 4 + what = 8?  Fill in the highlighted tile.",
                      "There are a few different directions you can take the puzzle from here, but let's look at the 2nd row.  You know that this row still needs 2 and 3, so you can use this info to figure out the highlighted tile.  2 x 3 x what = 24?",
                      "Great!  Now that we know where the 4 is in the first column, we can logic our way into the order of the '4x' cage.  Can you figure out which numbers go where?  Remember, two of the same number can't occupy the same row or column",
                      "Nice work.  Now put some of the tricks we've learned together, and figure out what goes in the '3x' cage in the bottom row.",
                      "You're really getting the hang of this!  Now fill in the '2x' cage.",
                      "Perfect!  From here, you should be able to figure out the rest of the tiles using everything you've learned so far.  See you on the other side.",
                      "Amazing work - you've really come a long way.  Keep all of these tips in mind when solving puzzles, and don't worry if you get stuck.  Remember, the color of the border tells you the puzzle's difficulty (if you forget, just click the '?' in the corner).  Until next time, partner."]
    var tutTagArr = [[],[2],[3],[7],[6],[8],[0,1],[12,13],[11,15],[4,5,9,10,14],[]]
    
    func pause(title: String, desc: String) {
        timer.invalidate()
        showPause(title: title, description: desc)
    }
    
    func startFirstTut() {
        //Delay for .25 sec
        
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            //Highlight the appropriate cells
            for tag in self.tutTagArr[self.progressCount] {
                if tag == 0 {self.tile = self.firstButton}
                else {self.tile = self.view.viewWithTag(tag) as! UIButton}
                self.tile.backgroundColor = UIColor(hue: 0.64, saturation: 0.26, brightness: 1.0, alpha: 0.5)
                self.tile.layer.cornerRadius = 12.0
                self.tile.clipsToBounds = true
            }
            self.pause(title: self.tutTitleArr[self.progressCount], desc: self.tutDescArr[self.progressCount])
            self.progressCount += 1

        }
    }
    
    func greyOut() {
        newPuzzle.isEnabled = false
        bg6.alpha = 0.3
        clearButton.isEnabled = false
        bg8.alpha = 0.3
        
    }
    
    func unGreyOut() {
        newPuzzle.isEnabled = true
        bg6.alpha = 0.75
        clearButton.isEnabled = true
        bg8.alpha = 0.75
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
            //Set tile text to input number
            buttonText = (sender.titleLabel?.text!)!
            button.setTitle(buttonText, for: UIControlState.normal)
            
            if button.tag < 16 {
                //Get index of tile to update field Array
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
                
                print(tutorialOver)
                // Check if progress is made in Tutorial
                if tutorialOver == false {
                    
                    var continueTut: Bool = false
                    outerLoop: for i in 0...3{
                        for j in 0...3 {
                            if currentField[i][j] == tutProgressArr[progressCount-2][i][j] {
                                continueTut = true
                            } else {
                                continueTut = false
                                break outerLoop
                            }
                        }
                    }
                    if continueTut == true {
                        startFirstTut()
                    }

                }
                
                // Check if currentField matches completedField
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
 
                // Check if tiles satisfy board rules
                let finish = checkIfCompleted()
                
                // If board follows all rules or matches generated board, accept
                if (match == true || finish == true) && tutorialOver == true {
                    timer.invalidate()
                    updateTimesArray(seconds: totalSeconds)
                    scoreBoard.addTime(difficulty: puzzleDifficulty, seconds: totalSeconds)
                    showPopUp(time: stopWatchString)
                    adCount += 1
                }
            }
            //Change views
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
    
    
    /*
     Function to check if board follows all rules, in the off chance that
     a board is generated with more than 1 possible solution.
     Returns true if answer is accetable, false otherwise
    */
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
                    //default value to return false
                    cageItem.valuesInCage[index!] = -100
                }
                cageValueArray[cageValue] = index!+1
            }
        }
        
        // Check if cages will not accept
        for cage in cageArray {
            if cage.cageWillAccept() == false {
                return false
            }
        }
        
        // Make sure there are no reapeats in rows or columns.
        // If not, return true
        if latinSquare(array: currentField) == false {
            return false
        } else {
            return true
        }
    }
    
    // Function to check is there are any repeated values in any rows or columns
    // Returns true is there are none, false otherwise
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
    
    // Simple function to check for repeated values in an array
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
    
    // Shows popOver View that shows completion message and finish time
    func showPopUp(time: String) {
        finishTime = time
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.delegate = self
        popOverVC.view.frame = (self.parent?.view.frame)!
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    
    func showPause(title: String, description: String) {
        pauseTitle = title
        pauseDesc = description
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPauseID") as! PauseViewController
        self.addChildViewController(popOverVC)
        popOverVC.delegate = self
        popOverVC.view.frame = (self.parent?.view.frame)!
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }

    
    
    
    
    // MARK: - Note (Hint) View
    
    // Shows the Hint view
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
    
    // Sets the hints of a tile
    // Accepts 2 in a row, then exits the view
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
    
    // Function that increments the counter
    // Called every second
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
    
    // Updates global array that stores total best times.  Saves in UserDefaults.
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
    
    // If board is empty, generate a new Puzzle.
    // Otherwise, ask the user if they want to generate a new puzzle
    @IBAction func generateButton(_ sender: Any) {
        if boardIsEmpty() {
            generatePuzzle()
        } else {
            self.displayAlert("Generate a New Puzzle?", message: "You will lose all progress on current puzzle")
        }
    }
    
    //Checks is the board is empty.  If so, return true.
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
    
    // Clears all progress on current board
    @IBAction func clearTiles(_ sender: Any) {
        
        for i in 0...47 {
            let tmpButton = self.view.viewWithTag(i) as? UIButton
            tmpButton?.setTitle(nil, for: .normal)
        }
        firstButton.setTitle(nil, for: .normal)
        currentField = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    }
    
    
    /*
     Generate a random field.
     Randomly selects a board png, then randomly assigns labels based on field.
    */
    func generatePuzzle() {
        unGreyOut()
        tutorialOver = true
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
    
    
    
    /*
        Generates tutorial starter puzzle.  Same every time, includeds tutorial
    */
    func generateFirstPuzzle() {
        // Reset Field
        field = KenKenField(blocks: 2)
        
        // Generate new field
        completedField = [[1,4,2,3],[2,3,1,4],[4,2,3,1],[3,1,4,2]]
        
        clearTiles(self)
        
        currentField = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        cageField = Array(repeating: Array(repeating: -1, count: 4), count: 4)
        cageArray = []
        
        // Pick a board
        // Number in arc4random is how many cage pngs we have to choose from
        let randNum = 5
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
        startFirstTut()
    }
    
    
    
    
    // Same as generatePuzzle(), but uses the same png board.
    // If in case some boards tend to recursively call generatePuzzle because of infractions
    // more than others, they will not get chosen any less frequently.
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
    }
    
    // Sets the board background to green if Easy, blue is Medium, and red is Hard
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
        
        /*
         HARCODED SECTION
         
         This section is where I have hardcoded which labels (hints) should be generated for each board png, as that is the easiest way to do it.
        */
        
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
            
            if playFirst == true {
                playFirst = false
                var result: String
                var a: Int
                
                // Set label0
                result = "4x"
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
                result = "8+"
                totalDifficulty += difficultyDictL[result]!
                cageField[0][3] = totalCages
                cageField[1][2] = totalCages
                cageField[1][3] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label3.text = result
                
                // Set label4
                result = "24x"
                totalDifficulty += difficultyDictL[result]!
                cageField[1][0] = totalCages
                cageField[1][1] = totalCages
                cageField[2][0] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label4.text = result
                
                // Set label9
                result = "9+"
                totalDifficulty += difficultyDictL[result]!
                cageField[2][1] = totalCages
                cageField[2][2] = totalCages
                cageField[3][2] = totalCages
                cageArray.append(Cage(size: 3, code: result))
                totalCages += 1
                label9.text = result
                
                // Set label11
                result = "2x"
                totalDifficulty += difficultyDictPair[result]!
                cageField[2][3] = totalCages
                cageField[3][3] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label11.text = result
                
                // Set label12
                result = "3x"
                totalDifficulty += difficultyDictPair[result]!
                cageField[3][0] = totalCages
                cageField[3][1] = totalCages
                cageArray.append(Cage(size: 2, code: result))
                totalCages += 1
                label12.text = result
                
                
            } else {
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
        setBG(view: mainbg)
        setBG(view: bg1)
        setBG(view: bg2)
        setBG(view: bg3)
        setBG(view: bg4)
        setBG(view: bg5)
        setBG(view: bg6)
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
    
    @IBOutlet var newPuzzle: UIButton!
    @IBOutlet var clearButton: UIButton!
    
    
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
    
    @IBAction func tapSound(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1306)
    }
    
    
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
        if interstitial.isReady && adCount % 3 == 0 {
            interstitial.present(fromRootViewController: self)
        } else {
            self.generatePuzzle()
        }
    }
    func resume() {
        // If puzzle has been completed
        if progressCount == tutTitleArr.count {
            generatePuzzle()
        } else {
            startTimer()
            if firstSlide == true {
                firstSlide = false
                startFirstTut()
            }
        }
    }
}

