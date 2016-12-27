//
//  Slide2ViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/15/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class Slide2ViewController: UIViewController {

    @IBOutlet var slant1: UIImageView!
    @IBOutlet var slant2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        slant1.layer.shadowColor = UIColor.black.cgColor
        slant1.layer.shadowOpacity = 0.4
        slant1.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        slant1.layer.shadowRadius = 5
        
        slant2.layer.shadowColor = UIColor.black.cgColor
        slant2.layer.shadowOpacity = 0.4
        slant2.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        slant2.layer.shadowRadius = 5

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
