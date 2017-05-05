//
//  HomeViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 11/10/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

var timesArray = [Int]()
var difficultyDictPair = [String: Int]()
var difficultyDictTriple = [String: Int]()
var difficultyDictL = [String: Int]()
var scoreBoard:Scoreboard = Scoreboard()
var starRank:StarRank = StarRank()

protocol ParentProtocol2 : class
{
    func method()
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellReuseIdentifier = "Cell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var shadowView: UIView!
    var timer:Timer = Timer()
    
    @IBAction func appReview(_ sender: Any) {
        let appID = "1181549788"
        let reviewString = "https://itunes.apple.com/us/app/id\(appID)?ls=1&mt=8&action=write-review"
        
        if let checkURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") {
            open(url: checkURL)
        } else {
            print("invalid url")
        }
    }
    
    func open(url: URL) {
        rateApp(appId: "id1181549788") { success in
            print("RateApp \(success)")
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self)
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 12.0
        tableView.clipsToBounds = true
        
        shadowView.layer.cornerRadius = 12.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shouldRasterize = true

        /*
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "new_title_3.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
            */
 
        updateBestTimes()
        
        configureDifficultyDict()
        
        scoreBoard.setTimes()
        starRank.setRank()
        
        checkIfFirstLaunch()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func segueWithName(name: String) {
        self.performSegue(withIdentifier: name, sender: self)
    }
    
    
    func updateBestTimes() {
        let defaults = UserDefaults.standard
        if let timesExist = defaults.object(forKey: "timesArray") {
            timesArray = timesExist as! [Int]
        } else {
            defaults.set(timesArray, forKey: "timesArray")
        }
    }
    
    func convertToTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let sec = seconds - (minutes*60)
        
        let secondsString = sec > 9 ? "\(sec)" : "0\(sec)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        return "\(minutesString):\(secondsString)"
    }
    
    
    
    // MARK: - Config Table View
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell
        
        cell.rankLabel.text = "\(String(indexPath.row + 1))."
        
        if indexPath.row > timesArray.count-1 {
            cell.timeLabel.text = ""
        } else {
            cell.timeLabel.text = convertToTime(seconds: timesArray[indexPath.row])
        }
        
        return cell
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    @IBAction func showTut(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tutorialView")
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func playPuzzle(_ sender: Any) {
        performSegue(withIdentifier: "playSegue", sender: self)
    }
    
    func playFirstPuzzle() {
        performSegue(withIdentifier: "playSegue", sender: self)
    }
    
    @IBAction func challengeMode(_ sender: Any) {
        performSegue(withIdentifier: "showChallenges", sender: self)
    }
    
    @IBAction func showScoreboard(_ sender: Any) {
        performSegue(withIdentifier: "showScoreboard", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Embed" {
            segue.destination.view.translatesAutoresizingMaskIntoConstraints = false
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

    func configureDifficultyDict() {
        // Set Pair Dict
        let labelArrPair:[String] = ["3+", "2x", "2÷", "1-", // (1,2)
                                     "4+", "3x", "3÷", "2-", // (1,3)
                                     "5+", "4x", "4÷", "3-", // (1,4)
                                     "5+", "6x", "1-",       // (2,3)
                                     "6+", "8x", "2÷", "2-", // (2,4)
                                     "7+", "12x", "1-"]      // (3,4)
        let subsetArrPair:[Int] = [1, 1, 2, 3, // (1,2)
                                   1, 1, 1, 2, // (1,3)
                                   2, 1, 1, 1, // (1,4)
                                   2, 1, 3,    // (2,3)
                                   1, 1, 2, 2, // (2,4)
                                   1, 1, 3]    // (3,4)
        for i in 0...labelArrPair.count-1 {
            difficultyDictPair[labelArrPair[i]] = subsetArrPair[i]
        }
        
        // Set Triple Dict
        let labelArrTriple: [String] = ["6+", "6x", // (1,2,3)
                                        "7+", "8x", // (1,2,4)
                                        "8+", "12x",// (1,3,4)
                                        "9+", "24x"]// (2,3,4)
        let subsetArrTriple: [Int] = [1, 1,
                                      1, 1,
                                      1, 1,
                                      1, 1]
        for i in 0...labelArrTriple.count-1 {
            difficultyDictTriple[labelArrTriple[i]] = subsetArrTriple[i]
        }
        
        // Set L Dict
        let labelArrL: [String] = ["6+", "6x", // (1,2,3)
                                   "7+", "8x", // (1,2,4)
                                   "8+", "12x",// (1,3,4)
                                   "9+", "24x",// (2,3,4)
                                   "4+", "2x", // (1,2,1)
                                   "5+", "3x", // (1,3,1)
                                   "6+", "4x", // (1,4,1)
                                   "5+", "4x", // (2,1,2)
                                   "7+", "12x",// (2,3,2)
                                   "8+", "16x",// (2,4,2)
                                   "7+", "9x", // (3,1,3)
                                   "8+", "18x",// (3,2,3)
                                   "10+", "36x",//(3,4,3)
                                   "9+", "16x", // (4,1,4)
                                   "10+", "32x",// (4,2,4)
                                   "11+", "48x"]//(4,3,4)
        let subsetArrL: [Int] = [2, 1,  // (1,2,3)
                                3, 1, // (1,2,4)
                                3, 2, // (1,3,4)
                                2, 1, // (2,3,4)
                                1, 1, // (1,2,1)
                                2, 1, // (1,3,1)
                                2, 2, // (1,4,1)
                                2, 2, // (2,1,2)
                                3, 2, // (2,3,2)
                                3, 2, // (2,4,2)
                                3, 1, // (3,1,3)
                                3, 1, // (3,2,3)
                                2, 1, // (3,4,3)
                                2, 2, // (4,1,4)
                                2, 1, // (4,2,4)
                                1, 1] // (4,3,4)
        for i in 0...labelArrL.count-1 {
            difficultyDictL[labelArrL[i]] = subsetArrL[i]
        }
        
        
    }
    
    
    func formatScoreboard() {
        
        scoreBoard.formatScoreBoard()
        
    }
    
    func checkIfFirstLaunch() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "appLaunched") != nil {
            return
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeViewController.result), userInfo: nil, repeats: true)
            defaults.set(true, forKey: "appLaunched")
        }
    }
    
    func result() {
        presentStartTut()
        timer.invalidate()
    }
    
    func presentStartTut() {
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbStartTutID") as! StartTutorialViewController
        self.addChildViewController(popOverVC)
        //popOverVC.delegate = self
        popOverVC.view.frame = (self.parent?.view.frame)!
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
 
    }
}

extension HomeViewController : ParentProtocol2 {
    func method() {
        performSegue(withIdentifier: "playSegue", sender: self)
    }
}
