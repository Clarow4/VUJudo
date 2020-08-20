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
    var top3List = [UserandRank]()
    var currentRankList = [UserandRank]()
    var currentDate = Date()
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
    
    func  getTodayWeekDay()-> String {
        var today = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: Date())
        today = weekDay
        return today
    }
    
 
    func createTop3Array(completed: @escaping () -> ()) {
        let today = getTodayWeekDay()
        var lastSunday: Date
        var targetSunday = "Week of "
        let formatter = DateFormatter()
        formatter.dateFormat = "M-dd-yyyy"
        
        //if today is Sunday, retrieve last Sunday's doc
        if today == "Sunday" {
            
            //get last Sunday's date
            lastSunday = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            targetSunday += formatter.string(from: lastSunday)
            print(targetSunday)
            
            
            //retrieve that date's document from firebase
            let doc = db.collection("leaderboard").document(targetSunday)
            doc.getDocument {(snapshot, error) in
                let data = snapshot?.data()
                var rankData = data?["1st"] as! [String : Any]
                var name = rankData["firstName"] ?? "" as String
                var score = rankData["score"] ?? 0 as Int
                var winnerData = UserandRank(Name: name as! String, Score: score as! Int)
                self.top3List.append(winnerData)
                
                rankData = data?["2nd"] as! [String : Any]
                name = rankData["firstName"] ?? "" as String
                score = rankData["score"] ?? 0 as Int
                winnerData = UserandRank(Name: name as! String, Score: score as! Int)
                self.top3List.append(winnerData)
                
                rankData = data?["3rd"] as! [String : Any]
                name = rankData["firstName"] ?? "" as String
                score = rankData["score"] ?? 0 as Int
                winnerData = UserandRank(Name: name as! String, Score: score as! Int)
                self.top3List.append(winnerData)
                
                completed()
                
            }
        }
        //if today is not Sunday, retrieve the most recent Sunday doc
        else {
            switch today {
                case "Monday" : do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                    targetSunday += formatter.string(from: lastSunday)
                    }
                case "Tuesday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
                    targetSunday += formatter.string(from: lastSunday)
                }
                case "Wednesday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
                    targetSunday += formatter.string(from: lastSunday)
                }
                case "Thursday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
                    targetSunday += formatter.string(from: lastSunday)
                }
                case "Friday": do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
                    targetSunday += formatter.string(from: lastSunday)
                }
                default: do {
                    lastSunday = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
                    targetSunday += formatter.string(from: lastSunday)
                }
            }
            //retrieve that date's document from firebase and store in an array list
                let doc = db.collection("leaderboard").document(targetSunday)
                doc.getDocument {(querySnapshot, error) in
                let data = querySnapshot?.data()
                    
                var rankData = data?["1st"] as! [String : Any]
                var name = rankData["firstName"] ?? "" as String
                var score = rankData["score"] ?? 0 as Int
                var winnerData = UserandRank(Name: name as! String, Score: score as! Int)
                self.top3List.append(winnerData)
    
                    
                rankData = data?["2nd"] as! [String : Any]
                name = rankData["firstName"] ?? "" as String
                score = rankData["score"] ?? 0 as Int
                winnerData = UserandRank(Name: name as! String, Score: score as! Int)
                self.top3List.append(winnerData)
                    
                rankData = data?["3rd"] as! [String : Any]
                name = rankData["firstName"] ?? "" as String
                score = rankData["score"] ?? 0 as Int
                winnerData = UserandRank(Name: name as! String, Score: score as! Int)
                self.top3List.append(winnerData)
                    
                completed()
               }
        }
    }
    
    
    
    //creates an array of this week's ranks and sorts them
    func getThisWeekRanks(completed: @escaping () -> ()) {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print("error in getting the user docs")
            }
            else {
                guard let querySnapshot = querySnapshot else {
                    print("error with querySnapshot in LWT3 array")
                    return
                }
                for document in querySnapshot.documents {
                    let data = document.data()
                    let userName = data["firstName"]
                    let userScore = data["score"]
                    let userToAdd: UserandRank = UserandRank(Name: userName as! String, Score: userScore as! Int)
                    self.currentRankList.append(userToAdd)
                }
                self.currentRankList = self.currentRankList.sorted(by: {$0.score > $1.score})

                completed()
            }
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.top3List.count+self.currentRankList.count+2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a blank LibraryTableCell
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
                }
                else {
                    let userAndScore = self.top3List[indexPath.row-1]
                    cell.rankText.text = String(indexPath.row) + ". " + userAndScore.name
                    cell.rankText.font = UIFont(name: "Baskerville", size: 20)
                    cell.rankText.textAlignment = .left
                }
            }
            else if (indexPath.row > self.top3List.count) {
                if indexPath.row == self.top3List.count+1{
                    cell.rankText.text = "This Week's Ranks"
                    cell.rankText.font = UIFont(name: "Baskerville-Bold", size: 30)
                    cell.rankText.textAlignment = .center
                }
                else {
                    let userAndScore = self.currentRankList[self.count]
                    cell.rankText.text = String(self.count+1) + ". " + userAndScore.name
                    cell.rankText.font = UIFont(name: "Baskerville", size: 20)
                    cell.rankText.textAlignment = .left
                    
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
