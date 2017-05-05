//
//  FourthTutVC.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/15/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class FourthTutVC: UIViewController {

    @IBOutlet var view4: UIView!
    @IBOutlet var board: UIImageView!
    @IBOutlet var blur1: UIVisualEffectView!
    @IBOutlet var blur2: UIVisualEffectView!
    @IBOutlet var rulesLabel: TopAlignedLabel!
    @IBAction func playExample(_ sender: UIButton) {
        playFirst = true
        tutorialOver = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view4.layer.shadowColor = UIColor.black.cgColor
        view4.layer.shadowOpacity = 0.4
        view4.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        view4.layer.shadowRadius = 4
        view4.layer.shouldRasterize = true
        
        board.layer.cornerRadius = 12.0
        board.clipsToBounds = true
        
        blur1.layer.cornerRadius = 12.0
        blur1.clipsToBounds = true
        
        blur2.layer.cornerRadius = 12.0
        blur2.clipsToBounds = true
        
        view4.layer.cornerRadius = 12.0
        
        rulesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        rulesLabel.numberOfLines = 0
        
        let rules:String = "Tap a tile to clear it.  You can then select a value, cancel the action, or insert a note (a reminder of possible values)."
        rulesLabel.text = rules
        rulesLabel.sizeToFit()

        /*
        let rules2:String = "And that's it!  Go solve some puzzles!"
        rulesLabel2.text = rules2
        rulesLabel2.sizeToFit()
        */
        
    }

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

}
