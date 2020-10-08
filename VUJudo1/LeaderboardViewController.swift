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

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var db: Firestore!
    
   @IBOutlet weak var tableView1: UITableView!
    var top3List = [UserandRank]() //last week's top 3 users
    var currentRankList = [UserandRank]() //array of this week's users and their scores
    var count: Int = 0
    
    @IBOutlet weak var topper: UIImageView!
    @IBOutlet weak var backArrow: UIImageView!
 
    
    
    override func viewWillAppear(_ animated: Bool) {
        getThisWeekRanks {
            self.tableView1.reloadData()
        }
        createTop3Array {
            self.tableView1.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
 
        self.count = 0
        
        tableView1.delegate = self
        tableView1.dataSource = self
    
    }
    
    var name = ""
    var score = 0
    var userData = UserandRank(Name: "", Score: 0)
    
    func createTop3Array(completed: @escaping () -> ()) {
        
        //get today's day
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let today = dateFormatter.string(from: Date())
        
        var lastSunday: Date
        var targetSunday = "Week of "
        dateFormatter.dateFormat = "M-d-yyyy"
        
        //if today is Sunday, retrieve last Sunday's doc
        if today == "Sunday" {
            
            //get last Sunday's date
            lastSunday = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            targetSunday += dateFormatter.string(from: lastSunday)
            
            //retrieve that date's document from firebase
            let leaderboardHistoryUsersDoc = db.collection("leaderboard_history").document(targetSunday).collection("users")

            leaderboardHistoryUsersDoc.getDocuments() { (querySnapshot, err) in
                //gather  all user history from leaderboardHIstoryDoc into top3List
                for doc in querySnapshot!.documents {
                    self.name = doc["firstName"] as! String
                    self.name += " "
                    self.name += doc["lastName"] as! String
                    self.score = doc["score"] as! Int
                    self.userData = UserandRank(Name: self.name, Score: self.score)
                    self.top3List.append(self.userData)
            }
                self.top3List = self.top3List.sorted(by: {$0.score > $1.score})
                self.top3List = Array(self.top3List.prefix(3))
                completed()
                
            }
        }
        //if today is not Sunday, retrieve the most recent Sunday doc
        else {
            switch today {
                case "Monday" : do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
                    targetSunday += dateFormatter.string(from: lastSunday)
                    }
                case "Tuesday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -9, to: Date())!
                    targetSunday += dateFormatter.string(from: lastSunday)
                }
                case "Wednesday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
                    targetSunday += dateFormatter.string(from: lastSunday)
                }
                case "Thursday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -11, to: Date())!
                    targetSunday += dateFormatter.string(from: lastSunday)
                }
                case "Friday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -12, to: Date())!
                    targetSunday += dateFormatter.string(from: lastSunday)
                }
                default: do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -13, to: Date())!
                    targetSunday += dateFormatter.string(from: lastSunday)
                }
            }

            //retrieve that date's document from firebase and store in an array list
                let leaderboardHistoryUsersDoc = db.collection("leaderboard_history").document(targetSunday).collection("users")

                leaderboardHistoryUsersDoc.getDocuments() { (querySnapshot, err) in
                    //gather  all user history from leaderboardHIstoryDoc into top3List
                    for doc in querySnapshot!.documents {
                        self.name = doc["firstName"] as! String
                        self.name += " "
                        self.name += doc["lastName"] as! String
                        self.score = doc["score"] as! Int
                        self.userData = UserandRank(Name: self.name, Score: self.score)
                        self.top3List.append(self.userData)
                }
                self.top3List = self.top3List.sorted(by: {$0.score > $1.score}) //sort the top3 array

                self.top3List = Array(self.top3List.prefix(3)) //shorten the top3 array to only include the top 3
                completed()
               }
        }
    }
    
    
    var userName = ""
    var userScore = 1
    var userToAdd = UserandRank(Name: "", Score: 0)
    
    //creates an array of this week's ranks and sorts them
    func getThisWeekRanks(completed: @escaping () -> ()) {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print("error in getting the user docs")
            }
            else {
                guard let querySnapshot = querySnapshot else {
                    print("error with querySnapshot in this week's ranks array")
                    return
                }
                for document in querySnapshot.documents {
                    self.userName = document["firstName"] as! String
                    self.userName += " "
                    self.userName += document["lastName"] as! String
                    self.userScore = document["score"] as! Int
                    self.userToAdd = UserandRank(Name: self.userName , Score: self.userScore )
                    self.currentRankList.append(self.userToAdd)
                }
                self.currentRankList = self.currentRankList.sorted(by: {$0.score > $1.score})

                completed()
            }
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.top3List.count+self.currentRankList.count+2)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a blank LeaderboardCell
          let cell =
              self.tableView1.dequeueReusableCell(withIdentifier:
              "rankCell", for: indexPath)
                      as! LeaderboardCell
        

        //makes sure the cells are loaded in correct order
        DispatchQueue.main.async {
            if(indexPath.row <= self.top3List.count) {
                if indexPath.row == 0 {
                    cell.rankText.text = "Last Week's Top 3"
                    cell.rankText.font = UIFont(name: "Baskerville-Bold", size: 30)
                    cell.rankText.textAlignment = .center
                    
                    cell.scoreText.text = ""
                }
                else {
                    let userAndScore = self.top3List[indexPath.row-1]
                    cell.rankText.text = String(indexPath.row) + ". " + userAndScore.name
                    cell.rankText.font = UIFont(name: "Baskerville", size: 20)
                    cell.rankText.textAlignment = .left
                    
                    cell.scoreText.text = " \(String(userAndScore.score)) points"
                    cell.scoreText.font = UIFont(name: "Baskerville", size: 20)
                    cell.scoreText.textAlignment = .right
                }
            }
            else //if (indexPath.row > self.top3List.count)/
            {
                if indexPath.row == self.top3List.count+1{
                    cell.rankText.text = "This Week's Ranks"
                    cell.rankText.font = UIFont(name: "Baskerville-Bold", size: 30)
                    cell.rankText.textAlignment = .center
                    
                    cell.scoreText.text = ""
                }
                else {
                    let userAndScore = self.currentRankList[self.count]
                    cell.rankText.text = String(self.count+1) + ". " + userAndScore.name
                    cell.rankText.font = UIFont(name: "Baskerville", size: 20)
                    cell.rankText.textAlignment = .left
                    
                    cell.scoreText.text = " \(String(userAndScore.score)) points"
                    cell.scoreText.font = UIFont(name: "Baskerville", size: 20)
                    cell.scoreText.textAlignment = .right
                    
                    self.count+=1
                }
   
            }
        }
        return cell
    }
    
    //back button to return home
    @IBAction func backButton(_ sender: Any) {
        self.performSegue(withIdentifier: "LeaderboardToHome", sender: self)
    }
    
}

class UserandRank {
    var name: String
    var score: Int
    
    init(Name: String, Score: Int) {
        self.name = Name
        self.score = Score
    }
}
