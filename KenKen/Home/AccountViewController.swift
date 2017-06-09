//
//  AccountViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/7/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit
import Firebase
import SwiftSpinner

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var InfoBG: UIView!
    @IBOutlet var gradBG: UIImageView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var parentVC:HomeViewController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.topItem?.title = "My Account"

        InfoBG.layer.cornerRadius = 20.0
        InfoBG.layer.borderColor = UIColor.black.cgColor
        InfoBG.layer.borderWidth = 0.25
        InfoBG.layer.shadowColor = UIColor.black.cgColor
        InfoBG.layer.shadowOpacity = 0.6
        InfoBG.layer.shadowRadius = 15
        InfoBG.layer.shadowOffset = CGSize(width: 5, height: 5)
        InfoBG.layer.masksToBounds = false
        InfoBG.clipsToBounds = true
        gradBG.layer.cornerRadius = 20.0
        gradBG.clipsToBounds = true
        gradBG.layer.borderColor = UIColor.black.cgColor
        gradBG.layer.borderWidth = 0.25

    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 1}
        else if section == 1 {return 3}
        else {return 1}
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { //Header Section
            let cell: AccountHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: "accountHeader") as! AccountHeaderCell
            if Auth.auth().currentUser != nil { // LOGGED IN
                cell.accountNameLabel.text = "\(appDelegate.user!.userName) \(appDelegate.user!.userSurname)"
                cell.accountEmailLabel.text = appDelegate.user!.userEmail
                cell.avatarImageView.image = UIImage(named: "avatar_\(appDelegate.user!.userAvatar)")
            } else {
                cell.accountNameLabel.text = "Error:"
                cell.accountEmailLabel.text = "Please log in to see info"
                cell.avatarImageView.image = UIImage(named: "avatar_anon")
            }
            
            return cell
        } else if indexPath.section == 1 {
            let cell:AccountBodyCell = self.tableView.dequeueReusableCell(withIdentifier: "accountBody") as! AccountBodyCell
            if Auth.auth().currentUser != nil { // LOGGED IN
                switch indexPath.row {
                case 0:
                    cell.boldLabel.text = "Best Easy Time"
                    if !appDelegate.user!.easyArray.isEmpty {cell.timeLabel.text = convertToTime(seconds: appDelegate.user!.easyArray[0])}
                    else {cell.timeLabel.text = ""}
                case 1:
                    cell.boldLabel.text = "Best Medium Time"
                    if !appDelegate.user!.mediumArray.isEmpty {cell.timeLabel.text = convertToTime(seconds: appDelegate.user!.mediumArray[0])}
                    else {cell.timeLabel.text = ""}
                default:
                    cell.boldLabel.text = "Best Hard Time"
                    if !appDelegate.user!.hardArray.isEmpty {cell.timeLabel.text = convertToTime(seconds: appDelegate.user!.hardArray[0])}
                    else {cell.timeLabel.text = ""}
                }
            } else {// ANON
                switch indexPath.row {
                case 0:
                    cell.boldLabel.text = "Best Easy Time"
                    if !scoreBoard.easyArray.isEmpty {cell.timeLabel.text = convertToTime(seconds: scoreBoard.easyArray[0])}
                    else {cell.timeLabel.text = ""}
                case 1:
                    cell.boldLabel.text = "Best Medium Time"
                    if !scoreBoard.mediumArray.isEmpty {cell.timeLabel.text = convertToTime(seconds: scoreBoard.mediumArray[0])}
                    else {cell.timeLabel.text = ""}
                default:
                    cell.boldLabel.text = "Best Hard Time"
                    if !scoreBoard.hardArray.isEmpty {cell.timeLabel.text = convertToTime(seconds: scoreBoard.hardArray[0])}
                    else {cell.timeLabel.text = ""}
                }
            }
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
            cell.boldLabel.sizeToFit()
            return cell
        } else {
            let cell:AccountLogOutCell = self.tableView.dequeueReusableCell(withIdentifier: "logOutCell") as! AccountLogOutCell
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Challenge Scoreboard"
//        } else if section == 1 {
//            return "Best Times Scoreboard"
//        } else {
//            return ""
//        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let title = UILabel()
//        title.textColor = UIColor.white
//        
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor=title.textColor
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {return 30}
        else {return 15}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {return 88.0}
        else {return 40.0}
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if Auth.auth().currentUser != nil {return 3}
        else {return 2}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        sectionSelected = indexPath.section
//        rowSelected = indexPath.row
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAvatar() {
        self.tableView.reloadData()
    }
    
    func convertToTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let sec = seconds - (minutes*60)
        
        let secondsString = sec > 9 ? "\(sec)" : "0\(sec)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        return "\(minutesString):\(secondsString)"
    }

    
    
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromAccount" {
            print("UNWIND")
            let homeVC = segue.destination as! HomeViewController
            homeVC.navigationController?.setNavigationBarHidden(false, animated: true)
        }
     }
    
    func showMessagePrompt(message:String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeAvatar(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            showMessagePrompt(message: "Please log in to select an avatar")
        } else {
            self.performSegue(withIdentifier: "showAvatar", sender: self)
        }
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        SwiftSpinner.show("Logging Out...")
        try! Auth.auth().signOut()
        appDelegate.user = nil
        parentVC.loginButton.setTitle("Log In", for: .normal)
        parentVC.userNameButton.isHidden = true
        parentVC.helloLabel.isHidden = true
        parentVC.myBestTimesLabel.isHidden = false
        tableView.reloadData()
        let when = DispatchTime.now() + 0.8
        DispatchQueue.main.asyncAfter(deadline: when){
            SwiftSpinner.hide()
            self.performSegue(withIdentifier: "unwindFromAccount", sender: self)
        }
    }
    
    

}
