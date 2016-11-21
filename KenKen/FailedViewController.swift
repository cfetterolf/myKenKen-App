//
//  FailedViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/19/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class FailedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bg1.layer.cornerRadius = 12.0
        bg1.clipsToBounds = true
        
        bg2.layer.cornerRadius = 12.0
        bg2.clipsToBounds = true
        
        finishedView.layer.cornerRadius = 15.0
        finishedView.clipsToBounds = true
        finishedView.layer.shadowColor = UIColor.black.cgColor
        finishedView.layer.shadowOpacity = 0.4
        finishedView.layer.shadowRadius = 3
        finishedView.layer.shadowOffset = CGSize(width: 3, height: 3)
        finishedView.layer.masksToBounds = false
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.showAnimate()
    }
    
    @IBAction func nextPuzzle(_ sender: Any) {
        self.removeAnimate()
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion:{(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
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
    @IBOutlet var finishedView: UIView!
    @IBOutlet var bg1: UIImageView!
    @IBOutlet var bg2: UIImageView!

}
