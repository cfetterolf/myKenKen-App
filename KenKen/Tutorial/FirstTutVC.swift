//
//  FirstTutVC.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/15/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class FirstTutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view1.layer.shadowColor = UIColor.black.cgColor
        view1.layer.shadowOpacity = 0.4
        view1.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        view1.layer.shadowRadius = 4
        view1.layer.shouldRasterize = true
        
        blur.layer.cornerRadius = 12.0
        blur.clipsToBounds = true
        
        view1.layer.cornerRadius = 12.0
        
        rulesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        rulesLabel.numberOfLines = 0
        
        let rules:String = "Rules of Fours:\n\n1. The only numbers you may use are 1, 2, 3, or 4.\n\n2. Every row and column must contain each number exactly once (like Sudoku).\n\n3. The numbers must follow the rules of their cage (see next slide for details)."
        rulesLabel.text = rules
        rulesLabel.sizeToFit()
        
        
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

    @IBOutlet var view1: UIView!
    @IBOutlet var blur: UIVisualEffectView!
    @IBOutlet var rulesLabel: UILabel!
    
}
