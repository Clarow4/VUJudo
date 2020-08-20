//
//  SignUpViewController.swift
//  VUJudo1
//
//  Created by Christina LaRow on 4/7/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import UIKit
import SwiftUI

import FirebaseAuth
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    var db: Firestore!
    
    //load page and set up firestore
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //[START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        //[END setup]
        
        db = Firestore.firestore()
    }
    

    //set up page elements
    @IBOutlet weak var blueTopper: UIImageView!
    
    
    @IBOutlet weak var VUJudoTopper: UILabel!
    
    
    @IBOutlet weak var firstName: UILabel!
    
    
    @IBOutlet weak var enterFirstName: UITextField!
    
    @IBOutlet weak var lastName: UILabel!
    
    @IBOutlet weak var enterLastName: UITextField!
    
    @IBOutlet weak var VUJudoMain: UILabel!
    
    @IBOutlet weak var enterEmail: UILabel!
    
   
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var enterPassword: UILabel!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UILabel!
    
    
    @IBOutlet weak var password2: UITextField!
    
    
    //execute when sign up button is clicked
    @IBAction func signUp(_ sender: Any) {
        
        //if any of the fields are empty send alert
        if enterFirstName.text?.isEmpty == true || enterLastName.text?.isEmpty == true || email.text?.isEmpty == true || password.text?.isEmpty == true || password2.text?.isEmpty == true {
            let emptyAlertController = UIAlertController(title: "Empty Fields", message: "Please make sure all of the fields are filled", preferredStyle: .alert)
            
            emptyAlertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(emptyAlertController, animated: true, completion: nil)
        }
        
        //first deal if the password and re-entered password do not match
        if password.text != password2.text {
            let alertController = UIAlertController(title: "Password Mis-match", message: "Please re-type password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true,  completion: nil)
        }
            
        //store user data in firebase if password and re-entered passwords are the same
        else {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!){ (authResult, error) in
            
                  if error == nil {
                    createUserDoc()
                    self.performSegue(withIdentifier: "SignUpToHome", sender: self)
                  }
                    
                //execute if there's an error trying to store data
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        //creates a document and adds it to the users collection in firestore
         func createUserDoc() {
            db.collection("users").document(email.text!).setData([
                "firstName": enterFirstName.text!,
                "lastName": enterLastName.text!,
                "email": email.text!,
                "score": 0,
            ]) {err in
                if let err = err {
                    let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
     }
    
}


struct SignUpViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIStoryboard(name:"Main", bundle: Bundle.main).instantiateInitialViewController()!.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        
    }
}

struct SignUpViewController_Previews: PreviewProvider {
    static var previews: some View {
        SignUpViewRepresentable()
    }
}
