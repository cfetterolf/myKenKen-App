//
//  ScoreBoardViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/19/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

var sectionSelected = 0
var rowSelected = 0

class ScoreBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = ""
        //self.navigationItem.title = "Scoreboard"
        
        tableView.layer.cornerRadius = 20.0
        tableView.clipsToBounds = true
        
        shadowView.layer.cornerRadius = 20.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        shadowView.layer.shadowRadius = 5
        
        totalScoreLabel.text = "Total Score:   \(starRank.totalRank)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Scoreboard"
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return scoreBoard.challengeArray.count
        } else {
            return 4
        }
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell2")
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = scoreBoard.challengeArray[indexPath.row]
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        } else if indexPath.section == 1 {
            let arr = ["All","Easy", "Medium", "Hard"]
            cell?.textLabel?.text = "\(arr[indexPath.row]) Puzzles"
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Challenge Scoreboard"
        } else if section == 1 {
            return "Best Times Scoreboard"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.white
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor=title.textColor
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sectionSelected = indexPath.section
        rowSelected = indexPath.row
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueToScore" {
            
            
            
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var shadowView: UIView!
    @IBOutlet var totalScoreLabel: UILabel!

}
