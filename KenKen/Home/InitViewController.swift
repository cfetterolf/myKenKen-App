//
//  InitViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/15/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit
import Firebase

class InitViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Check if logged in
        if Auth.auth().currentUser != nil { // LOGGED IN
            //loginButton.setTitle("Log Out", for: .normal)
            appDelegate.user = User(email: "", name: "", surname: "", password: "")
            appDelegate.user!.logIn(completionHandler: { (success) -> Void in
                //Show Home
                self.performSegue(withIdentifier: "showHome", sender: self)
            })
        } else { //NOT LOGGED IN
            self.performSegue(withIdentifier: "showHome", sender: self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
