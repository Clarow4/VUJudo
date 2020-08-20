//
//  HomeViewController.swift
//  VUJudo1
//
//  Created by Christina LaRow on 4/8/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import Firebase
import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    let user = Auth.auth().currentUser
    var db: Firestore!
    var scores = [Int]()
    var counter = 0
    var rankInt = 0
    
  
    //creates an array of all the scores--> helps calculate rank
    func createScoresArray(completed: @escaping () -> ()) {
        db.collection("users").getDocuments() { (querySnapshot, err) in
               if let err = err {
                   print("error in the exercise array: \(err)")
               }
               else {
                   guard let querySnapshot = querySnapshot else {
                       print("error with querySnapshot in exercise Array")
                       return
                   }
                   for document in querySnapshot.documents {
                       let data = document.data()
                       let fieldValue = data["score"]
                       
                    self.scores.append(fieldValue as! Int)
                   }
                self.scores.sort(by: >)
                   completed()
               }
           }
    }
    
    
    //retrieves the data from the specified email document
    //and sets the data to the name, score, and rank in the topper
    func getDocumentValues() {
        let doc = db.collection("users").document((user?.email)!)
        
        doc.getDocument {(snapshot, error) in
            if let data = snapshot?.data() {
                var fieldValue = data["firstName"]
                self.name.text = fieldValue as? String
                
                fieldValue = data["score"]
                self.score.text = "Score: \(fieldValue!)"
            
                //calculate rank based on score
                if(self.scores.isEmpty == false) {
                    for item in self.scores {
                        if(fieldValue as! Int == item) {
                            self.rankInt = self.counter + 1
                            break
                        }
                        
                        self.counter+=1
                    }
                    
                    let lastRankDigit = self.rankInt % 10
                    switch(lastRankDigit) {
                        case 1:
                            self.rank.text = "Rank: " + String(self.rankInt) + "st"
                        case 2:
                            self.rank.text = "Rank: " + String(self.rankInt) + "nd"
                        case 3:
                            self.rank.text = "Rank: " + String(self.rankInt) + "rd"
                        default:
                            self.rank.text = "Rank: " + String(self.rankInt) + "th"
                        }
                }
               
            }
            //send error in case setting any of the user data fails
            else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    

    //load page and set up firestore
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings

        db = Firestore.firestore()
        
       // getDocumentValues()
        createScoresArray {
            self.getDocumentValues()
        }
        
        setDailyTechnique {
            print("filler code")
        }
    }
    
    
    
    @IBOutlet weak var name: UILabel!
    
    
    @IBOutlet weak var topper: UIImageView!
    

    @IBOutlet weak var rank: UILabel!
    
    @IBOutlet weak var score: UILabel!
    
   
    @IBOutlet weak var dailyTechnique: UILabel!
    
    
    @IBAction func dailyTechniqueButton(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToLog", sender: self)
    }
    
    var passedName = ""
    func setDailyTechnique(completed: @escaping () -> ()) {
         db.collection("waza").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("error in the exercise array: \(err)")
                }
                else {
                    guard let querySnapshot = querySnapshot else {
                        print("error with querySnapshot in exercise Array")
                        return
                    }
                    for document in querySnapshot.documents {
                        let data = document.data()
                        let dataName = data["name"] as! String
                        let isDailyAssignment = data["dailyAssignment"] as? Bool
                        
                        if isDailyAssignment == true {
                            self.passedName = dataName
                            self.dailyTechnique.text = "Today's \nTechnique"
                        }
                     
                    }
                    completed()
                }
            }
     }
  
    
    @IBAction func Leaderboard(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToLeaderboard", sender: self)
    }
    
    
    @IBAction func selectExercise(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToLibrary", sender: self)
    }
    
    
    
    //pass email from this View to next so next View can access firestore doc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "HomeToLog" {
            if let nextVC = segue.destination as? LogViewController {
                nextVC.previousScreen = "Home"
                nextVC.exerciseName = self.passedName
                nextVC.isWaza = true
            }
        }
        else if segue.identifier == "HomeToLibrary" {
            if let nextVC = segue.destination as? LibraryViewController {
                nextVC.passedName = "Home"
            }
        }
    }
    
}
