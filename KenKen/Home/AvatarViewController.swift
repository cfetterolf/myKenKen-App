//
//  AvatarViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/7/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit
import Firebase

class AvatarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let reuseIdentifier = "cell"
    var avatarNames = ["steph", "golden", "aussie", "block_dude"]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.backgroundColor = .clear
        self.collectionView.backgroundView = nil
    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.avatarNames.count
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! AvatarCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.image.image = UIImage(named: "avatar_\(self.avatarNames[indexPath.item])")
//        cell.frame.size.width = 100
//        cell.frame.size.height = 100
        
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: CGFloat((collectionView.frame.size.width / 3) + 20), height: CGFloat(100))
//    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let selectedAvatar = avatarNames[indexPath.item]
        appDelegate.user!.userAvatar = selectedAvatar
        
        // UPDATE FIREBASE
        let ref = Database.database().reference(withPath: "users/\((Auth.auth().currentUser?.uid)!)")
        ref.setValue(appDelegate.user!.toAnyObject())
        
        let queryRef = Database.database().reference(withPath: "leaderboard")
        
        //UPDATE Leaderboards
        if (!appDelegate.user!.bestArray.isEmpty){queryRef.child("best-leaderboard").child((Auth.auth().currentUser?.uid)!).updateChildValues(["avatar": selectedAvatar])}
        if (!appDelegate.user!.easyArray.isEmpty){queryRef.child("easy-leaderboard").child((Auth.auth().currentUser?.uid)!).updateChildValues(["avatar": selectedAvatar])}
        if (!appDelegate.user!.mediumArray.isEmpty){queryRef.child("medium-leaderboard").child((Auth.auth().currentUser?.uid)!).updateChildValues(["avatar": selectedAvatar])}
        if (!appDelegate.user!.hardArray.isEmpty){queryRef.child("hard-leaderboard").child((Auth.auth().currentUser?.uid)!).updateChildValues(["avatar": selectedAvatar])}
        
        //Exit back home
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
