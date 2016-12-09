//
//  ScoreDetailTableViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/23/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class ScoreDetailTableViewController: UITableViewController {
    
    var localStarRank:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.rowHeight = 60.0
        
        if sectionSelected == 0 {
            self.navigationItem.title = "\(scoreBoard.challengeArray[rowSelected])"
        } else {
            let arr = ["All Puzzles", "Easy Puzzles", "Medium Puzzles", "Hard Puzzles"]
            self.navigationItem.title = "\(arr[rowSelected])"
        }
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        localStarRank = 0
        computeTotalScore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        // CHALLENGE Detail
        if sectionSelected == 0 {
            return 4
        } else {
            
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if sectionSelected == 0 {
            if section < 3 {
                return 5
            } else {
                return 1
            }
        } else {
            if section < 1 {
                return 10
            } else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // CHALLENGE Detail
        if sectionSelected == 0 {
            if section < 3 {
                return "\(scoreBoard.difficultyArray[rowSelected][section]) Puzzle"
            } else {
                return "Total Score for \(scoreBoard.challengeArray[rowSelected])"
            }
        } else {
            if section == 0 {
                return "Times"
            } else {
                let arr = ["All Puzzles", "Easy Puzzles", "Medium Puzzles", "Hard Puzzles"]
                return "Total Score for \(arr[rowSelected])"
            }
        }
        
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ScoreboardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! ScoreboardTableViewCell

        // Configure the cell...
        
        
        if sectionSelected == 0 {
            
            if indexPath.section < 3 {
                cell.rankLabel.text = "\(indexPath.row+1)."
                
                if indexPath.row > scoreBoard.timesArray[rowSelected][indexPath.section].count-1 {
                    cell.timeLabel.text = ""
                    cell.starRank.image = nil
                    cell.totalScoreLabel.text = ""
                } else {
                    cell.timeLabel.text = "\(self.formatTime(sec: scoreBoard.timesArray[rowSelected][indexPath.section][indexPath.row]))"
                    cell.totalScoreLabel.text = ""
                    setStarRank(time: scoreBoard.timesArray[rowSelected][indexPath.section][indexPath.row], cell: cell)
                }
            } else {
                cell.totalScoreLabel.text = "\(localStarRank)"
                cell.starRank.image = nil
                cell.timeLabel.text = ""
                cell.rankLabel.text = ""
            }
        } else {
            
            var timesArr:[Int] = []
            
            // All Puzzles
            if rowSelected == 0 {
                timesArr = timesArray
            }
            
            // Easy Puzzles
            else if rowSelected == 1 {
                timesArr = scoreBoard.easyArray
            }
            
            // Medium Puzzles
            else if rowSelected == 2 {
                timesArr = scoreBoard.mediumArray
            }
            
            // Hard Puzzles
            else if rowSelected == 3 {
                timesArr = scoreBoard.hardArray
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

        }
        
        
        return cell
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
        title.textColor = UIColor.white
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor=title.textColor
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
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
