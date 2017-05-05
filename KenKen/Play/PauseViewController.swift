//
//  PauseViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 5/4/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

var pauseTitle: String = ""
var pauseDesc: String = ""
var pauseHeight: Int = 0
var tutProgressArr = [  [[0,0,2,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]],
                        [[0,0,2,3],[0,0,0,0],[0,0,0,0],[0,0,0,0]],
                        [[0,0,2,3],[0,0,0,4],[0,0,0,0],[0,0,0,0]],
                        [[0,0,2,3],[0,0,1,4],[0,0,0,0],[0,0,0,0]],
                        [[0,0,2,3],[0,0,1,4],[4,0,0,0],[0,0,0,0]],
                        [[1,4,2,3],[0,0,1,4],[4,0,0,0],[0,0,0,0]],
                        [[1,4,2,3],[0,0,1,4],[4,0,0,0],[3,1,0,0]],
                        [[1,4,2,3],[0,0,1,4],[4,0,0,1],[3,1,0,2]],
                        [[1,4,2,3],[2,3,1,4],[4,2,3,1],[3,1,4,2]]]

class PauseViewController: UIViewController {

    @IBOutlet var myTextView: UITextView!
    @IBOutlet var transView: UIView!
    @IBOutlet var transTitle: UILabel!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var okButton: UIButton!
    
    @IBAction func unPause(_ sender: Any) {
        self.removeAnimate()
        callDelegate()
        
    }
    
    // Dismiss view on outside touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view != transView {
                self.removeAnimate()
                callDelegate()
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        transTitle.text = pauseTitle
        myTextView.text = pauseDesc
        
        //print(transDecription.frame.height)
        
        transView.layer.cornerRadius = 15.0
        transView.layer.shadowColor = UIColor.black.cgColor
        transView.layer.shadowOpacity = 0.4
        transView.layer.shadowRadius = 3
        transView.layer.shadowOffset = CGSize(width: 3, height: 3)
        transView.layer.masksToBounds = false
        
        //Format heights
        myTextView.sizeToFit()
        if pauseTitle == "Easy Cages" {topConstraint.constant -= 100}
        if (pauseTitle == "More Logic" || pauseTitle == "Welcome to Fours!" || pauseTitle == "Starter Tiles") {
            topConstraint.constant -= 50
        }
        if pauseTitle == "Awesome!" {topConstraint.constant -= 175}
        if pauseTitle == "Great Work!" {topConstraint.constant -= 210}
        if pauseTitle == "Fantastic!" {
            topConstraint.constant -= 200
            okButton.setTitle("Finish", for: .normal)
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        //configureLabels()
        self.showAnimate()

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
    
    weak var delegate : ParentProtocol?
    
    func callDelegate () {
        delegate?.resume()
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
