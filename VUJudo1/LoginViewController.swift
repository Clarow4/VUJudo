//
//  LoginViewController.swift
//  VUJudo1
//
//  Created by Christina LaRow on 4/7/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import JavaScriptCore

class LoginViewController: UIViewController{
    
    var jsContext: JSContext!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeJS()
        self.callJSMethods()
        db = Firestore.firestore()
      //  let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func initializeJS() {
        self.jsContext = JSContext()
        
        let functions = self.jsContext.objectForKeyedSubscript("functions")
        let admin = self.jsContext.objectForKeyedSubscript("admin")
        let schedule = self.jsContext.objectForKeyedSubscript("schedule")
        
        let jsDB = self.jsContext.objectForKeyedSubscript("db")
        

        //specify the path to the js file
        if let jsSourcePath = Bundle.main.path(forResource: "app", ofType: "js") {
            do {
                //Load its contents to a String cariable
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                
                self.jsContext.evaluateScript(jsSourceContents)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func callJSMethods() {
        if let jsMethod1 =  self.jsContext.objectForKeyedSubscript("setLeaderboardHistory") {
            if let getLeaderboardHist = jsMethod1.call(withArguments: nil) {
                print("success?")
            }
        }

    }
    

    @IBOutlet weak var VUJudoTopper: UILabel!
    
    @IBOutlet weak var blueTopper: UIImageView!
    
    @IBOutlet weak var VUJudo: UILabel!
    
    @IBOutlet weak var enterEmail: UILabel!
    
    
    @IBOutlet weak var email: UITextField!
    
    
    @IBOutlet weak var enterPassword: UILabel!
    
    @IBOutlet weak var password: UITextField!


    @IBSegueAction func LoginToHomeSegue(_ coder: NSCoder) -> HomeViewController? {
        return HomeViewController(coder: coder)
    }

    @IBAction func signUpButton(_ sender: Any) {
        self.performSegue(withIdentifier: "LoginToSignUp", sender: self)
    }
    
    
    
    @IBAction func loginAction(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!)
                    {(authResult, error) in
                //execute if there's no error in signing in
                if(error == nil) {
                    self.performSegue(withIdentifier: "LoginToHome", sender: self)
                }
                
                //execute if there is an error
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        //check if email is actually stored in the system
        Auth.auth().sendPasswordReset(withEmail: email.text!) {
            error in DispatchQueue.main.async {
                
                //send error if email field is empty
                if self.email.text?.isEmpty == true || error != nil {
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: please fill in the email field and then click Forgot Password", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }
                
                //if the email is in the system and the email field is not empty send reset email
                if error == nil && self.email.text?.isEmpty == false {
                    let resetEmailAlertSent = UIAlertController(title: "Reset Email Sent", message: "Reset email has been sent to your login email", preferredStyle: .alert)
                    resetEmailAlertSent.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailAlertSent, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
    

