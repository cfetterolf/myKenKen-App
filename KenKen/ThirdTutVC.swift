//
//  ThirdTutVC.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/15/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class ThirdTutVC: UIViewController {
    
    @IBOutlet var view3: UIView!
    @IBOutlet var board: UIImageView!
    @IBOutlet var blur1: UIVisualEffectView!
    @IBOutlet var blur2: UIVisualEffectView!
    @IBOutlet var rulesLabel: TopAlignedLabel!
    @IBOutlet var rulesLabel2: TopAlignedLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view3.layer.shadowColor = UIColor.black.cgColor
        view3.layer.shadowOpacity = 0.4
        view3.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        view3.layer.shadowRadius = 4
        view3.layer.shouldRasterize = true
        
        board.layer.cornerRadius = 12.0
        board.clipsToBounds = true
        
        blur1.layer.cornerRadius = 12.0
        blur1.clipsToBounds = true
        
        blur2.layer.cornerRadius = 12.0
        blur2.clipsToBounds = true
        
        view3.layer.cornerRadius = 12.0
        
        rulesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        rulesLabel.numberOfLines = 0
        
        rulesLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
        rulesLabel2.numberOfLines = 0
        
        let rules:String = "Note: Numbers may be repeated within the same cage, so long as they are in different rows and columns."
        rulesLabel.text = rules
        rulesLabel.sizeToFit()
        
        let rules2:String = "Tap \"New Puzzle\" to  generate a random puzzle.\nTap \"Clear\" to clear all tiles."
        rulesLabel2.text = rules2
        rulesLabel2.sizeToFit()
        
        

        // Do any additional setup after loading the view.
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
