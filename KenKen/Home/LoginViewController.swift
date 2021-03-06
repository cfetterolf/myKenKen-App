//
//  LoginViewController.swift
//  KenKen
//
//  Created by Chris Fetterolf on 5/30/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftSpinner
import AudioToolbox

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var userEmail: String = ""
    var userPassword: String = ""
    var userName: String = ""
    var userSurname: String = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
//        fhandle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            // ...
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Auth.auth().removeStateDidChangeListener(handle)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        navBar.topItem?.title = "Log In"
        loginEmailError.text = ""
        loginPassError.text = ""
        signupEmailError.text = ""
        signupPassError.text = ""
        
        InfoBG.layer.cornerRadius = 20.0
        InfoBG.layer.borderColor = UIColor.black.cgColor
        InfoBG.layer.borderWidth = 0.25
        InfoBG.layer.shadowColor = UIColor.black.cgColor
        InfoBG.layer.shadowOpacity = 0.6
        InfoBG.layer.shadowRadius = 15
        InfoBG.layer.shadowOffset = CGSize(width: 5, height: 5)
        InfoBG.layer.masksToBounds = false
        InfoBG.clipsToBounds = true
        gradBG.layer.cornerRadius = 20.0
        gradBG.clipsToBounds = true
        gradBG.layer.borderColor = UIColor.black.cgColor
        gradBG.layer.borderWidth = 0.25
        
        //Format Various Views
        formatBackground(view: loginBG)
        formatBackground(view: signupBG)
        
        self.loginEmailForm.delegate = self
        self.loginPassForm.delegate = self
        self.signupEmailForm.delegate = self
        self.signupNameForm.delegate = self
        self.signupSurnameForm.delegate = self
        self.signupPassForm.delegate = self
        
        signupView.isHidden = true

        // Do any additional setup after loading the view.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if textField == self.loginPassForm {
            self.login(self)
        } else if textField == self.signupPassForm {
            self.signUp(self)
        }
        return true
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
    
    @IBAction func login(_ sender: Any) {
        SwiftSpinner.show("Logging In...")
        Auth.auth().signIn(withEmail: loginEmailForm.text!, password: loginPassForm.text!) { (user, error) in
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                SwiftSpinner.hide()
                if let error = error {
                    self.showMessagePrompt(message: error.localizedDescription)
                    return
                }
                self.appDelegate.user = User(email: "testEmail", name: "", surname: "", password: "")
                self.appDelegate.user!.logIn(completionHandler: {(success) -> Void in
                    self.callDelegate()
                    self.performSegue(withIdentifier: "unwindFromLogin", sender: self)
                })
            }
        }
        
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        if self.loginEmailForm.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        } else {
            
            Auth.auth().sendPasswordReset(withEmail: self.loginEmailForm.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.loginEmailForm.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })

        }

        
    }
    
    
    
    @IBAction func signUp(_ sender: Any) {
        // [START create_user]
        SwiftSpinner.show("Signing Up...")
        
        Auth.auth().createUser(withEmail: signupEmailForm.text!, password: signupPassForm.text!) { (user, error) in
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                // [START_EXCLUDE]
                SwiftSpinner.hide()
                if let error = error {
                    self.showMessagePrompt(message: error.localizedDescription)
                    return
                }
                
                let ref = Database.database().reference(withPath: "users")
                self.appDelegate.user = User(email: self.signupEmailForm.text!, name: self.signupNameForm.text!, surname: self.signupSurnameForm.text!, password: self.signupPassForm.text!)
                let currentUserRef = ref.child(user!.uid)
                currentUserRef.setValue(self.appDelegate.user?.toAnyObject())
                
                
                print("\(user!.email!) created")
                //self.updateUserInfo(userID: user!.uid, userEmail: user!.email!)
                self.callDelegate()
                self.performSegue(withIdentifier: "unwindFromLogin", sender: self)
                
                // [END_EXCLUDE]
                
            }
        }
        // [END create_user]
    }
    
    func showMessagePrompt(message:String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func updateUserInfo(userID:String, userEmail:String) {
        
    }

    
    // Type should be either "email" or "password"
    func validate(type: String, content: String) -> Bool {
        if type == "email" {
            // Validate email address
            if isValidEmail(testStr: content) {return true}
            return false
        } else if type == "password" {
            // Validate Password
            if isValidPassword(testStr: content) {return true}
            return false
        }
        else {return false}
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPassword(testStr:String) -> Bool {
        if testStr == "" {return false}
        return true
    }
    
    
    @IBAction func switchLogin(_ sender: Any) {
        signupView.isHidden = true
        loginView.isHidden = false
        navBar.topItem?.title = "Log In"
    }
    @IBAction func switchSignup(_ sender: Any) {
        signupView.isHidden = false
        loginView.isHidden = true
        navBar.topItem?.title = "Sign Up"
    }
    
    
    weak var delegate : HomeDelegate?
    
    func callDelegate() {
        delegate?.changeLogin()
    }

    
    
    
    @IBOutlet var InfoBG: UIView!
    @IBOutlet var gradBG: UIImageView!
    @IBOutlet var navBar: UINavigationBar!
    
    @IBOutlet var loginView: UIView!
    @IBOutlet var loginBG: UIView!
    
    @IBOutlet var loginEmailView: UIView!
    @IBOutlet var loginEmailForm: UITextField!
    @IBOutlet var loginEmailIcon: UIImageView!
    @IBOutlet var loginEmailError: UILabel!
    
    @IBOutlet var loginPassView: UIView!
    @IBOutlet var loginPassForm: UITextField!
    @IBOutlet var loginPassIcon: UIImageView!
    @IBOutlet var loginPassError: UILabel!
    
    @IBOutlet var signupView: UIView!
    @IBOutlet var signupBG: UIView!
    
    @IBOutlet var signupEmailView: UIView!
    @IBOutlet var signupEmailForm: UITextField!
    @IBOutlet var signUpEmailIcon: UIImageView!
    @IBOutlet var signupEmailError: UILabel!
    
    @IBOutlet var signupPassView: UIView!
    @IBOutlet var signupPassForm: UITextField!
    @IBOutlet var signupPassIcon: UIImageView!
    @IBOutlet var signupPassError: UILabel!
    
    @IBOutlet var signupNameView: UIView!
    @IBOutlet var signupNameForm: UITextField!
    @IBOutlet var signupNameIcon: UIImageView!
    
    @IBOutlet var signupSurnameView: UIView!
    @IBOutlet var signupSurnameForm: UITextField!
    @IBOutlet var signupSurnameIcon: UIImageView!
    
    
    
    
    func formatBackground(view: UIView) {
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromLogin" {
            segue.destination.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    

}

extension LoginViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
