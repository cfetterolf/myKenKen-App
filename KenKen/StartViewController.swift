//
//  StartViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/20/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

var currentPuzzle = 0

class StartViewController: UIViewController {

    weak var delegate:StartViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bg1.layer.cornerRadius = 12.0
        bg1.clipsToBounds = true
        
        finishedView.layer.cornerRadius = 15.0
        finishedView.layer.borderColor = UIColor.black.cgColor
        finishedView.layer.borderWidth = 0.25
        finishedView.layer.shadowColor = UIColor.black.cgColor
        finishedView.layer.shadowOpacity = 0.6
        finishedView.layer.shadowRadius = 15
        finishedView.layer.shadowOffset = CGSize(width: 5, height: 5)
        finishedView.layer.masksToBounds = false
        
        // Config start time
        initCountdown = currentChallenge.initCountdownArray[currentChallenge.nextPuzzleIndex]
        let minutes = initCountdown / 60
        let seconds = initCountdown - (60*minutes)
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = String(minutes)
        let stopWatchString = "\(minutesString):\(secondsString)"
        finishLabel.text = "You have \(stopWatchString) to complete this \(currentChallenge.difficultyArray[currentChallenge.nextPuzzleIndex]) puzzle"
        
        puzzleTitle.text = "Puzzle \((currentChallenge.nextPuzzleIndex) + 1)"
        
    }
    
    @IBAction func startChallenge(_ sender: Any) {
        delegate?.didFinishTask(sender: self)
    }
    
    
    /*
    @IBAction func nextPuzzle(_ sender: Any) {
        self.removeAnimate()
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion:{(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBOutlet var finishedView: UIView!
    @IBOutlet var bg1: UIImageView!
    @IBOutlet var finishLabel: UILabel!
    @IBOutlet var puzzleTitle: UILabel!

}
