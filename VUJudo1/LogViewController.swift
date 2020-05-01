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

class LogViewController: UIViewController {

    var previousScreen: String?
    var logDocEmail: String?
    var db: Firestore!
    
    //retrieveis the data from the specified email document
    //and sets the data to the name, score, and rank in the topper
    func getDocumentValues() {
        let doc = db.collection("users").document(logDocEmail!)
        
        doc.getDocument {(snapshot, error) in
            if let data = snapshot?.data() {
                var fieldValue = data["firstName"]
                self.name.text = fieldValue as? String
                
                fieldValue = data["rank"]
                self.rank.text = "Rank: \(fieldValue!)"
                
                fieldValue = data["score"]
                self.score.text = "Score: \(fieldValue!)"
            }
            else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //[START setup]
         let settings = FirestoreSettings()
         Firestore.firestore().settings = settings
         //[END setup]
         
         db = Firestore.firestore()
        getDocumentValues()
    }
    
    
    //topper elements
    
    @IBOutlet weak var blueTopper: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    
    @IBOutlet weak var rank: UILabel!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var backArrow: UIImageView!
    
    
    @IBSegueAction func LogToHome(_ coder: NSCoder) -> HomeViewController? {
        return HomeViewController(coder: coder)
    }
    @IBAction func backArrowButton(_ sender: Any) {
        var segue = "LogTo"
        segue += previousScreen!
        self.performSegue(withIdentifier: segue, sender: self)
    }
    
    
    @IBOutlet weak var logTitle: UILabel!
    
    
    //logging elements
    @IBOutlet weak var exerciseLabelFiller: UILabel!
    
    @IBOutlet weak var enterRepsFiller: UILabel!
    
    //select exercise elements
    var exercises = [String]()
    var selectedExercise: String?
    //add elements using a while loop and fieldValue process from above- while(fieldValue != null) {fieldValue = data[exerciseName]
    //once all the elements are in the array, load the array into UIPicker View
    var selectedReps: String?

    @IBAction func submit(_ sender: Any) {
        //take the stored exercise name and reps number and run algorithm that determines how many points user gains from exercise and store it in firebase
    }
    
    
    
    //passes email variable to the next View during segue so it can access firestore
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "LogToHome" {
               if let nextVC = segue.destination as? HomeViewController {
                   nextVC.docEmail = logDocEmail
               }
               else {
                   print("error")
               }
           }
           else if segue.identifier == "LogToLeadership" {
               if let nextVC = segue.destination as? LeadershipViewController {
               nextVC.leadershipDocEmail = logDocEmail
               }
           }
           else if segue.identifier == "LogToLibrary" {
                if let nextVC = segue.destination as? LibraryViewController {
                nextVC.libraryDocEmail = logDocEmail
                }
            }
       }
    
    
}
