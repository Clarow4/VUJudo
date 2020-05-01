//
//  LibraryViewController.swift
//  VUJudo1
//
//  Created by Christina LaRow on 4/28/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//


import UIKit
import SwiftUI
import Firebase

class LibraryViewController: UIViewController {
    
    var previousScreen: String?
    var libraryDocEmail: String?
    var db: Firestore!
    
    //retrieveis the data from the specified email document
    //and sets the data to the name, score, and rank in the topper
    func getDocumentValues() {
        let doc = db.collection("users").document(libraryDocEmail!)
        
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
        
        //[START setup of firestore]
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
    
    
    //uchikomi elements--> only need the tableView outlet
    @IBOutlet weak var tableView: UITableView!
    
    
    //***
    //check to see if there is a function that allows you to
    //write directly to a table cell. If yes- loop through firestore
    //uchikomi database and write in the waza that way so we can dynamically
    //add more uchikomi suggestions
    //***
    
    
    //tab bar elements
    @IBOutlet weak var tabBar: UIToolbar!
    
    @IBAction func homeTab(_ sender: Any) {
        self.performSegue(withIdentifier: "LibraryToHome", sender: self)
    }
    
    @IBAction func logTab(_ sender: Any) {
              self.performSegue(withIdentifier: "LibraryToLog", sender: self)
    }
    
    @IBAction func leadershipTab(_ sender: Any) {
              self.performSegue(withIdentifier: "LibraryToLeadership", sender: self)
    }
    
    @IBAction func libraryTab(_ sender: Any) {
    }
    
    
    //passes email variable to the next View during segue so it can access firestore
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "LibraryToHome" {
               if let nextVC = segue.destination as? HomeViewController {
                   nextVC.docEmail = libraryDocEmail
               }
           }
           else if segue.identifier == "LibraryToLog" {
               if let nextVC = segue.destination as? LogViewController {
               nextVC.logDocEmail = libraryDocEmail
               }
           }
           else if segue.identifier == "LibraryToLeadership" {
                if let nextVC = segue.destination as? LeadershipViewController {
                nextVC.leadershipDocEmail = libraryDocEmail
                }
            }
       }
    
    
}
