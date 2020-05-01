//
//  LeadershipBoardViewController.swift
//  VUJudo1
//
//  Created by Christina LaRow on 4/25/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase

class LeadershipViewController: UIViewController {
    
    var leadershipDocEmail: String?
    var db: Firestore!
    
    //retrieveis the data from the specified email document
    //and sets the data to the name, score, and rank in the topper
    func getDocument() {
        let doc = db.collection("users").document(leadershipDocEmail!)
        
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
        getDocument()
    
    }
    
   //topper elements
    
    @IBOutlet weak var blueTopper: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var rank: UILabel!
    
    @IBOutlet weak var score: UILabel!
    
    //scroll elements
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollContent: UIView!
    
    @IBOutlet weak var leadershipBoard: UILabel?
    
    //last week elements
    @IBOutlet weak var lastWeek: UILabel?
    
    @IBOutlet weak var LWfirstPlace: UILabel! //last week first place
    
    @IBOutlet weak var LWsecondPlace: UILabel!
    
    
    @IBOutlet weak var LWthirdPlace: UILabel!
    
    //this week elements
    @IBOutlet weak var thisWeek: UILabel!
    
    @IBOutlet weak var firstPlace: UILabel!
    
    
    @IBOutlet weak var secondPlace: UILabel!
    
    
    @IBOutlet weak var thirdPlace: UILabel!
    
    @IBOutlet weak var fourthPlace: UILabel!
    
    @IBOutlet weak var fifthPlace: UILabel!
    
    @IBOutlet weak var sixthPlace: UILabel!
    
    @IBOutlet weak var seventhPlace: UILabel!
    
    @IBOutlet weak var eighthPlace: UILabel!
    
    @IBOutlet weak var ninthPlace: UILabel!
    
    @IBOutlet weak var tenthPlace: UILabel!
    
    @IBOutlet weak var eleventhPlace: UILabel!
    
    @IBOutlet weak var twelfthPlace: UILabel!
    
    @IBOutlet weak var thirteenthPlace: UILabel!
    
    @IBOutlet weak var fourteenthPlace: UILabel!
    
    @IBOutlet weak var fifteenthPlace: UILabel!
    
    @IBOutlet weak var sixteenthPlace: UILabel!
    
    @IBOutlet weak var seventeenthPlace: UILabel!
    
    @IBOutlet weak var eighteenthPlace: UILabel!
    
    @IBOutlet weak var ninteenthPlace: UILabel!
    
    @IBOutlet weak var twemtiethPlace: UILabel!
    
    //tab bar elements
    @IBOutlet weak var tabBar: UIToolbar!
    
    @IBAction func homeTab(_ sender: Any) {
        self.performSegue(withIdentifier: "LeadershipToHome", sender: self)
    }
    
    @IBAction func logTab(_ sender: Any) {
         self.performSegue(withIdentifier: "LeadershipToLog", sender: self)
    }
    
    @IBAction func leadershipTab(_ sender: Any) {
    }
    @IBAction func libraryTab(_ sender: Any) {
         self.performSegue(withIdentifier: "LeadershipToLibrary", sender: self)
    }
    
    
    
    //passes email variable to the next View during segue so it can access firestore
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LeadershipToHome" {
            if let nextVC = segue.destination as? HomeViewController {
                nextVC.docEmail = leadershipDocEmail
            }
            else {
                print("error")
            }
        }
        else if segue.identifier == "LeadershipToLog" {
            if let nextVC = segue.destination as? LogViewController {
            nextVC.logDocEmail = leadershipDocEmail
            }
        }
        else if segue.identifier == "LeadershipToLibrary" {
            if let nextVC = segue.destination as? LibraryViewController {
            nextVC.libraryDocEmail = leadershipDocEmail
            }
        }
    }
    
    
}
