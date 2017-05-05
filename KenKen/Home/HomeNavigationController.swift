//
//  HomeNavigationController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 5/4/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

class HomeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playFirstPuzzle() {
        let firstVC = self.viewControllers[0] as! HomeViewController
        firstVC.playFirstPuzzle()
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
