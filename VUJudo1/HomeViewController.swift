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
    
    var docEmail: String?
    var db: Firestore!
    
  
    //retrieves the data from the specified email document
    //and sets the data to the name, score, and rank in the topper
    func getDocumentValues() {
        let doc = db.collection("users").document(docEmail!)
        
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
    
    //load page and set up firestore
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //[START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        //[END setup]

        db = Firestore.firestore()
        getDocumentValues()
    }
    
   
    @IBOutlet weak var VUJudoTopper: UILabel!
    
    
    @IBOutlet weak var name: UILabel!
    
    
    @IBOutlet weak var topper: UIImageView!
    

    @IBOutlet weak var rank: UILabel!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var dailyAssignment: UILabel!
    
    @IBAction func logExercise(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToLog", sender: self)
    }
    
    @IBAction func selectExercise(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToLibrary", sender: self)
    }
    
    
    @IBSegueAction func HomeToLog(_ coder: NSCoder) -> LogViewController? {
        return LogViewController(coder: coder)
    }
    
    @IBSegueAction func HomeToLibrary(_ coder: NSCoder) -> LibraryViewController? {
        return LibraryViewController(coder: coder) 
    }
    
    
    //pass email from this View to next so next View can access firestore doc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToLeadership" {
            if let nextVC = segue.destination as? LeadershipViewController {
                nextVC.leadershipDocEmail = docEmail
            }
        }
        else if segue.identifier == "HomeToLog" {
            if let nextVC = segue.destination as? LogViewController {
                nextVC.logDocEmail = docEmail
                nextVC.previousScreen = "Home"
            }
        }
        else if segue.identifier == "HomeToLibrary" {
            if let nextVC = segue.destination as? LibraryViewController {
                nextVC.libraryDocEmail = docEmail
                nextVC.previousScreen = "Home"
            }
        }
    }
    
    
    
}
