//
//  ScoreDetailTableViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/23/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Firebase

class ScoreDetailTableViewController: UITableViewController {
    
    let arr = ["Best Times","Easy Times","Medium Times","Hard Times"]
    var bestTimesArr:[LeaderboardTime] = []
    var easyTimesArr:[LeaderboardTime]  = []
    var mediumTimesArr:[LeaderboardTime]  = []
    var hardTimesArr:[LeaderboardTime]  = []
    var localStarRank:Int = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        self.tableView.rowHeight = 60.0
        
        if sectionSelected == 0 {
            self.navigationItem.title = arr[rowSelected]
        } else {
            let arr = ["All Puzzles", "Easy Puzzles", "Medium Puzzles", "Hard Puzzles"]
            self.navigationItem.title = "\(arr[rowSelected])"
        }
        self.navigationController?.navigationBar.topItem?.title = ""
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
        
//        localStarRank = 0
//        computeTotalScore()
        
        
        
        // MARK: - Real time updates
        let rootRef = Database.database().reference(withPath: "leaderboard")
        
        
        //UPDATES BEST
        rootRef.child("best-leaderboard").queryOrdered(byChild: "time").queryLimited(toFirst: 50).observe(.childAdded, with: { (snapshot) -> Void in
            if !snapshot.exists() {return}
            let value = snapshot.value as! NSDictionary
            let time = LeaderboardTime(time: value["time"] as! Int, name: value["name"] as! String, avatar: value["avatar"] as! String)
            if !self.bestTimesArr.contains(time) {self.bestTimesArr.append(time)}
            self.tableView.reloadData()
        })
        
        //UPDATE EASY
        rootRef.child("easy-leaderboard").queryOrdered(byChild: "time").queryLimited(toFirst: 50).observe(.childAdded, with: { (snapshot) -> Void in
            if !snapshot.exists() {return}
            let value = snapshot.value as! NSDictionary
            let time = LeaderboardTime(time: value["time"] as! Int, name: value["name"] as! String, avatar: value["avatar"] as! String)
            if !self.easyTimesArr.contains(time) {self.easyTimesArr.append(time)}
            self.tableView.reloadData()
        })
        
        //UPDATE MEDIUM
        rootRef.child("medium-leaderboard").queryOrdered(byChild: "time").queryLimited(toFirst: 50).observe(.childAdded, with: { (snapshot) -> Void in
            if !snapshot.exists() {return}
            let value = snapshot.value as! NSDictionary
            let time = LeaderboardTime(time: value["time"] as! Int, name: value["name"] as! String, avatar: value["avatar"] as! String)
            if !self.mediumTimesArr.contains(time) {self.mediumTimesArr.append(time)}
            self.tableView.reloadData()
        })
        
        //UPDATE HARD
        rootRef.child("hard-leaderboard").queryOrdered(byChild: "time").queryLimited(toFirst: 50).observe(.childAdded, with: { (snapshot) -> Void in
            if !snapshot.exists() {return}
            let value = snapshot.value as! NSDictionary
            let time = LeaderboardTime(time: value["time"] as! Int, name: value["name"] as! String, avatar: value["avatar"] as! String)
            if !self.hardTimesArr.contains(time) {self.hardTimesArr.append(time)}
            self.tableView.reloadData()
        })



        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if sectionSelected == 0 {
            return 50
        } else {
            return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // CHALLENGE Detail
        if sectionSelected == 0 {
            return arr[section]
        } else {
            return "Times"
        }
        
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        
        
        if sectionSelected == 0 {
            
            let cell:LeaderboardCell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! LeaderboardCell
            
            var timesArr:[LeaderboardTime]!
            
            switch rowSelected {
            case 0:
                timesArr = bestTimesArr
            case 1:
                timesArr = easyTimesArr
            case 2:
                timesArr = mediumTimesArr
            default:
                timesArr = hardTimesArr
            }
            
            if indexPath.row > timesArr.count-1 {
                cell.rankLabel.text = "\(indexPath.row+1)."
                cell.avatarLabel.image = nil
                cell.nameLabel.text = ""
                cell.timeLabel.text = ""
            } else {
                cell.rankLabel.text = "\(indexPath.row+1)."
                cell.timeLabel.text = self.formatTime(sec: timesArr[indexPath.row].time)
                cell.nameLabel.text = timesArr[indexPath.row].name
                cell.avatarLabel.image = UIImage(named: "avatar_\(timesArr[indexPath.row].avatar)")
            }

            return cell
            
        } else {
            
            let cell:ScoreboardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! ScoreboardTableViewCell
            
            var timesArr:[Int] = []
            let loggedIn:Bool = (Auth.auth().currentUser != nil)
            
            // All Puzzles
            if rowSelected == 0 {
                // CHECK IF USER LOGGED IN
                if (loggedIn) {
                    if (appDelegate.user != nil) {
                        timesArr = appDelegate.user!.bestArray
                    }
                } else {
                   timesArr = timesArray
                }
            }
            
            // Easy Puzzles
            else if rowSelected == 1 {
                if (loggedIn) {
                    if (appDelegate.user != nil) {
                        timesArr = appDelegate.user!.easyArray
                    }
                } else {
                    timesArr = scoreBoard.easyArray
                }
            }
            
            // Medium Puzzles
            else if rowSelected == 2 {
                if (loggedIn) {
                    if (appDelegate.user != nil) {
                        timesArr = appDelegate.user!.mediumArray
                    }
                } else {
                    timesArr = scoreBoard.mediumArray
                }
            }
            
            // Hard Puzzles
            else if rowSelected == 3 {
                if (loggedIn) {
                    if (appDelegate.user != nil) {
                        timesArr = appDelegate.user!.hardArray
                    }
                } else {
                    timesArr = scoreBoard.hardArray
                }
            }
            
            if indexPath.section < 1 {
                if indexPath.row > timesArr.count-1 {
                    cell.rankLabel.text = "\(indexPath.row+1)."
                    cell.starRank.image = nil
                    cell.totalScoreLabel.text = ""
                    cell.timeLabel.text = ""
                } else {
                    cell.rankLabel.text = "\(indexPath.row+1)."
                    cell.timeLabel.text = "\(self.formatTime(sec: timesArr[indexPath.row]))"
                    cell.totalScoreLabel.text = ""
                    setStarRank(time: timesArr[indexPath.row], cell: cell)
                }
            } else {
                cell.totalScoreLabel.text = "\(localStarRank)"
                cell.starRank.image = nil
                cell.timeLabel.text = ""
                cell.rankLabel.text = ""
            }
            
             return cell

        }
        
    }
    
    func setStarRank(time:Int, cell:ScoreboardTableViewCell) {
        if time < 60 && time >= 40 {
            cell.starRank.image = UIImage(named: "star_bronze.png")
            //starRank.addToRank(num: 1)
            //localStarRank += 1
        } else if time < 40 && time >= 25 {
            cell.starRank.image = UIImage(named: "star_silver.png")
            //starRank.addToRank(num: 2)
            //localStarRank += 2
        } else if time < 25 {
            cell.starRank.image = UIImage(named: "star_gold.png")
            //starRank.addToRank(num: 3)
            //localStarRank += 3
        } else {
            cell.starRank.image = nil
        }
    }
    
    func computeTotalScore() {
        if sectionSelected == 0 {
            for sect in 0...2 {
                let timesArr = scoreBoard.timesArray[rowSelected][sect]
                for time in timesArr {
                    if time < 60 && time >= 40 {
                        localStarRank += 1
                    } else if time < 40 && time >= 25 {
                        localStarRank += 3
                    } else if time < 25 {
                        localStarRank += 10
                    }
                }
            }
        } else {
            
            var timesArr:[Int] = []
            
            if rowSelected == 0 {
                timesArr = timesArray
            } else if rowSelected == 1 {
                timesArr = scoreBoard.easyArray
            } else if rowSelected == 2 {
                timesArr = scoreBoard.mediumArray
            } else {
                timesArr = scoreBoard.hardArray
            }

            for time in timesArr {
                if time < 60 && time >= 40 {
                    localStarRank += 1
                } else if time < 40 && time >= 25 {
                    localStarRank += 3
                } else if time < 25 {
                    localStarRank += 10
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.darkGray
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor=title.textColor
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    
    func formatTime(sec: Int) -> String {
        let minutes = sec / 60
        let seconds = sec - (60*minutes)
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        return "\(minutesString):\(secondsString)"
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
