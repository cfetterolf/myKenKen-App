//
//  ChallengeMenuViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/19/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

var countdown = 0
var initCountdown = 40
var performSG = false
var performSGFinish = false
var firstPuzzle = true

var currentChallenge:Challenge = Challenge(countdownArray: [], diffArray: [], numPuzzles: 0)


let easyGreen = UIColor(hue: 0.275, saturation: 0.4, brightness: 0.84, alpha: 0.8)
let mediumBlue = UIColor(hue: 0.5778, saturation: 0.67, brightness: 0.84, alpha: 0.8)
let hardRed = UIColor(hue: 0.99, saturation: 0.25, brightness: 0.84, alpha: 0.8)

class ChallengeMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Dimmable {
    
    @IBOutlet var tableView: UITableView!
    let cellReuseIdentifier = "Challenge Cell"
    let difficultyOptions = ["Easy", "Medium", "Hard"]
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Challenges"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView.backgroundColor = UIColor(hue: 0.5389, saturation: 0.18, brightness: 0.94, alpha: 1.0)
        // Do any additional setup after loading the view.
        //InfoViewController.delegate = self
         tableView.backgroundColor = .clear
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return difficultyOptions.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ChallengeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ChallengeTableViewCell
        
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        
        
        if difficultyOptions[indexPath.row] == "Easy" {
            cell.difficultyBG.backgroundColor = easyGreen
            cell.challengeName.text = "Easy"
            cell.challengeDescription.text = "To learn and grow"
        } else if difficultyOptions[indexPath.row] == "Medium" {
            cell.difficultyBG.backgroundColor = mediumBlue
            cell.challengeName.text = "Medium"
            cell.challengeDescription.text = "To hone your skills"
            
        } else if difficultyOptions[indexPath.row] == "Hard" {
            cell.difficultyBG.backgroundColor = hardRed
            cell.challengeName.text = "Hard"
            cell.challengeDescription.text = "For the brave at heart"
            
        } else {
            cell.difficultyBG.backgroundColor = .clear
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a Challenge:"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func printVal() {
        print(0)
    }
    
    // method to run when table view cell is tapped
    //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You tapped cell number \(indexPath.row).")
    //}



    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segueToChallenge(_ sender: Any) {
        print("OK")
        performSegue(withIdentifier: "segueToChallenge", sender: self)
    }
    
    /*
    @IBAction func beginChallenge(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToChallenge", sender: self)
        
    }
    */
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showInfo() {
        self.performSegue(withIdentifier: "showInfo", sender: self)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showInfo" {
            dim(direction: .In, alpha: dimLevel, speed: dimSpeed)
            //let infoView = segue.destination as! InfoViewController
            //infoView.delegate = self
        } else if segue.identifier == "segueToChallenge" {
            //let destView = segue.destination as! ChallengeViewController
            //destView.CHALLENGE_MODE = selectedDiff
        }
        
    }
    
    @IBAction func unwindFromSecondary(segue: UIStoryboardSegue) {
        dim(direction: .Out, speed: dimSpeed)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func unwindFromChallenge(segue: UIStoryboardSegue) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

}
