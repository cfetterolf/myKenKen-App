//
//  ExtensionsViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/20/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

enum Direction { case In, Out }

protocol Dimmable { }

extension Dimmable where Self: UIViewController {
    
    func dim(direction: Direction, color: UIColor = UIColor.black, alpha: CGFloat = 0.0, speed: Double = 0.0) {
        
        switch direction {
        case .In:
            
            // Create and add a dim view
            let dimView = UIView(frame: view.frame)
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            view.addSubview(dimView)
            
            // Deal with Auto Layout
            dimView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            
            // Animate alpha (the actual "dimming" effect)
            UIView.animate(withDuration: speed) { () -> Void in
                dimView.alpha = alpha
            }
            
        case .Out:
            UIView.animate(withDuration: speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha
            }, completion: { (complete) -> Void in
                self.view.subviews.last?.removeFromSuperview()
                
                if performSG == true {
                    self.performSegue(withIdentifier: "segueToChallenge", sender: self)
                    firstPuzzle = true
                    performSG = false
                } else if (performSGFinish == true) {
                    self.navigationController?.popViewController(animated: true)
                    performSGFinish = false
                }
                
                
            })
        }
    }
}
