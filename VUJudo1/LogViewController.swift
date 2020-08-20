//
//  LogViewController.swift
//  VUJudo1
//
//  Created by Christina LaRow on 4/27/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseAuth

class LogViewController: UIViewController {

    var previousScreen: String?
    var exerciseName: String = ""
    var db: Firestore!
    var isWaza: Bool?
    
    var datePicker = UIDatePicker()
    var pickerToolbar: UIToolbar?
    var selectedDate: String?
    
    var wazaMultiplier: Int?
    var exerciseMultiplier: Int?
    var pointsEarned: Int?
    var reps: Int?
    var userEmail: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //[START setup]
         let settings = FirestoreSettings()
         Firestore.firestore().settings = settings
         //[END setup]
         
         db = Firestore.firestore()
        
         setScoreMultipliers()
        
         dailyTechnique?.text = exerciseName
        
        
        //create Toolbar for Cancel and Done buttons
        createDatePickerToolBar()
        
        //set date picker mode to dd/mm/yyyy
        datePicker.datePickerMode = .date
        
        //add toolbar to textField
        dateTextField?.inputAccessoryView = pickerToolbar
        
        //add datepicker to textField
        dateTextField?.inputView = datePicker
    }
    
    
    //get wazaMultiplier and exerciseMultiplier values from firebase
    func setScoreMultipliers() {
      let doc = db.collection("config").document("Score Multipliers")
        doc.getDocument {(snapshot, error) in
            if let data = snapshot?.data() {
                var fieldValue = data["Waza Multiplier"]
                self.wazaMultiplier = fieldValue as? Int
                
                fieldValue = data["Exercise Multiplier"]
                self.exerciseMultiplier = fieldValue as? Int
                    
                
            }
            else {
                self.wazaMultiplier = 50
                self.exerciseMultiplier = 10
                print("Error retrieving score multipliers")
            }
        }
    }

    
    //topper elements
    @IBOutlet weak var blueTopper: UIImageView!
    @IBOutlet weak var VuJudo: UILabel!
    
    @IBOutlet weak var backArrow: UIImageView!
    
    @IBSegueAction func LogToHome(_ coder: NSCoder) -> HomeViewController? {
        return HomeViewController(coder: coder)
    }
    @IBAction func backArrowButton(_ sender: Any) {
        var segue = "LogTo"
        segue += previousScreen!
        self.performSegue(withIdentifier: segue, sender: self)
    }
    
    
    
    //logging elements
    @IBOutlet weak var dailyTechnique: UILabel!
    @IBOutlet weak var enterReps: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    //create the tool bar above the date picker witht eh done and cancel buttons
    func createDatePickerToolBar() {
        
        pickerToolbar = UIToolbar()
        pickerToolbar?.autoresizingMask = .flexibleHeight
        
        //customize the toolbar
        pickerToolbar?.barStyle = .default
        pickerToolbar?.barTintColor = UIColor.systemBlue
        pickerToolbar?.backgroundColor = UIColor.white
        pickerToolbar?.isTranslucent = false
        
        //add buttons
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtnClicked(_:)))
        cancelButton.tintColor = UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(LogViewController.doneBtnClicked(_:)))
        doneButton.tintColor = UIColor.white
        //add buttons to the toolbar
        pickerToolbar?.items = [cancelButton, flexSpace, doneButton]
        
    }
    @objc func cancelBtnClicked(_ button: UIBarButtonItem) {
        dateTextField?.resignFirstResponder()
    }
    
    @objc func doneBtnClicked(_ button: UIBarButtonItem) {
        dateTextField?.resignFirstResponder()
        let formatter = DateFormatter()
       
        formatter.dateStyle = .medium
        dateTextField?.text = formatter.string(from: datePicker.date)
        
        selectedDate = dateTextField?.text
    }
    
    
    //Step 1- find current user, add to their score
    //Step 2- check if Practice Log collection already exists in current user doc. If yes- add to it. If no- create collection within user doc with document name  Practice Log
    //Step 3- Check for document within Practice Log with name "selectedDate". If yes- edit it. If no- create it
    //Step 4- Check if field "exercise" exists in selectedDate document. If yes- add to it. If no- create it
    
    @IBAction func submit(_ sender: Any) {
        reps = Int(enterReps.text!)
        
        //make sure reps and date have been entered
        if selectedDate != nil && reps! > 0 {
            
            //Easter egg
            if reps! >= 500 {
                let easterEggAlert = UIAlertController(title: "Bullshit", message: "Christina calls bullshit on this. There's no way you did more than 500 reps. But I'll count it anyway.", preferredStyle: .alert)
                easterEggAlert.addAction(UIAlertAction(title: "My bad", style: .cancel))
                self.present(easterEggAlert, animated: true, completion: nil)
            }
            //step 1
            if let user = Auth.auth().currentUser {
                let userDoc = db.collection("users").document(user.email!)
                
                //step 2
                let dateDoc = db.collection("users").document(user.email!).collection("Practice Log").document(selectedDate!)
                
                //get user's score and update it to reflect new logged exercise
                userDoc.getDocument {(snapshot, error) in
                   if let data = snapshot?.data() {
                        var fieldValue = data["score"] as? Int
                        if self.isWaza == true {
                            self.pointsEarned = self.reps! * self.wazaMultiplier!
                        }
                        else {
                            self.pointsEarned = self.reps! * self.exerciseMultiplier!
                        }
                        fieldValue = fieldValue! + self.pointsEarned!
                        userDoc.updateData(["score" : fieldValue!])
                    }
                    
                    //step 3 and step 4
                     dateDoc.getDocument{(snapshot, error) in
                        //if exerciseName does exist in dateDoc, modify the new reps
                        if let data = snapshot?.get(self.exerciseName) {
                            let newReps = self.reps! + ((data as? Int)!)
                            dateDoc.updateData([self.exerciseName: newReps])
                         }
                        //if exerciseName does not exist in dateDoc, add it
                         else {
                            var exerciseInfo: [String: Int] = [:]
                            exerciseInfo[self.exerciseName] = self.reps
                            dateDoc.setData(exerciseInfo, merge: true)
                         }
                     }
                }
            }
            let sucessAlert = UIAlertController(title: "Successful Submission", message: nil,  preferredStyle:  UIAlertController.Style.actionSheet)
                
            self.present(sucessAlert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                sucessAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
                
            enterReps.text = ""
            dateTextField.text = ""
        }

          
            
        //if reps or selectedDate are empty/0
        else {
            let emptyAlertController = UIAlertController(title: "Empty Fields", message: "Please make sure you have entered in a valid number of reps and that you have selected a date", preferredStyle: .alert)
            emptyAlertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(emptyAlertController, animated: true, completion: nil)
        }
    }
    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
}
