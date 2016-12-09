//
//  HelpViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 12/3/16.
//  Copyright © 2016 DeepHouse. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var shadowView: UIView!
    
    
    
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
