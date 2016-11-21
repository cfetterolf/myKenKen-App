//
//  SecondTutVC.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/15/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class SecondTutVC: UIViewController {

    @IBOutlet var view2: UIView!
    @IBOutlet var board: UIImageView!
    @IBOutlet var blur: UIVisualEffectView!
    @IBOutlet var rulesLabel: TopAlignedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view2.layer.shadowColor = UIColor.black.cgColor
        view2.layer.shadowOpacity = 0.4
        view2.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        view2.layer.shadowRadius = 4
        view2.layer.shouldRasterize = true
        
        board.layer.cornerRadius = 12.0
        board.clipsToBounds = true
        
        blur.layer.cornerRadius = 12.0
        blur.clipsToBounds = true
        
        view2.layer.cornerRadius = 12.0
        
        rulesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        rulesLabel.numberOfLines = 0
        
        let rules:String = "The numbers in a bolded region, called a cage, must follow the operation in the upper left corner.\n\nFor example, the circled cage follows the rule, since 4 + 1 = 5."
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

}
