//
//  PlayHelpViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 12/6/16.
//  Copyright © 2016 DeepHouse. All rights reserved.
//

import UIKit

class PlayHelpViewController: UIViewController {

    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var shadowView: UIView!
    
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        
        blurView.layer.cornerRadius = 20.0
        blurView.clipsToBounds = true
        
        shadowView.layer.cornerRadius = 20.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        shadowView.layer.shadowRadius = 10
        
        image1.layer.cornerRadius = 12.0
        image1.clipsToBounds = true
        image2.layer.cornerRadius = 12.0
        image2.clipsToBounds = true
        image3.layer.cornerRadius = 12.0
        image3.clipsToBounds = true
        
        image1.backgroundColor = easyGreen
        image2.backgroundColor = mediumBlue
        image3.backgroundColor = hardRed
        
        
        
        
        
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
