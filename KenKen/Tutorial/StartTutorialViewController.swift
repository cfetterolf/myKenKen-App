//
//  StartTutorialViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/28/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class StartTutorialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelView2.frame = CGRect(x: self.view.frame.width, y: buttonView.frame.origin.y, width: labelView2.frame.width, height: labelView2.frame.height)

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        formatView(view: labelView)
        formatView(view: buttonView)
        formatView(view: labelView2)
        self.showAnimate()
    }

    
    @IBAction func exitHome(_ sender: Any) {
        
        slideToNext()
        //self.removeAnimate()
    }
    
    func slideToNext() {
        
        UIView.animate(withDuration: 0.25) {
            //Annimate out current views
            self.slideFrame(view: self.labelView)
            self.slideFrame(view: self.buttonView)
            self.slideFrame(view: self.imageView)
            
            
            let frameSize: CGPoint = CGPoint(x: (UIScreen.main.bounds.size.width*0.5)-self.labelView2.frame.width/2, y: self.labelView2.frame.origin.y)
            self.labelView2.frame = CGRect(origin: frameSize, size: self.labelView2.frame.size)
        }
    }
    
    func slideFrame(view: UIView) {
        view.frame = CGRect(x: (view.frame.origin.x - self.view.frame.width), y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
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
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var labelView: UIView!
    @IBOutlet var labelView2: UIView!
    @IBOutlet var buttonView: UIView!
    @IBAction func takeTutorial(_ sender: Any) {
        self.removeAnimate()
    }
    @IBAction func noThanks(_ sender: Any) {
        self.removeAnimate()
    }
    
    func formatView(view: UIView) {
        view.layer.cornerRadius = 15.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 3
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.masksToBounds = false
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
