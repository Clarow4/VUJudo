//
//  LibraryViewController.swift
//  VUJudo1
//
//  Created by Christina LaRow on 6/14/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import SwiftUI
import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseFirestoreSwift

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //variables
    var count: Int = 0
    var db: Firestore!
    
    var waza = [String]()
    var exercise = [String]()
    
    
    @IBOutlet weak var topperView: UIView!
    @IBOutlet weak var blueRectangle: UIImageView!
    @IBOutlet weak var VUJudo: UILabel!
    @IBOutlet weak var backArrow: UIImageView!
   
    @IBAction func backButton(_ sender: Any) {
        self.performSegue(withIdentifier: "LibraryToHome", sender: self)
    }
    

    //create waza and exercise arrays
    func createExerciseArray(completed: @escaping () -> ()){
        db.collection("exercises").getDocuments() { (querySnapshot, err) in
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
                    let fieldValue = data["name"]
                    
                    self.exercise.append(fieldValue as! String)
                }
                completed()
            }
        }

    }
    
    
    func createWazaArray(completed: @escaping () -> ()) {
         db.collection("waza").getDocuments() {(querySnapshot, err) in
             if let err = err {
                 print("We got an error: \(err)")
             }
             else {
                 guard let querySnapshot = querySnapshot else {
                        print("Error in part 2")
                        return
                 }
                 for document in querySnapshot.documents {
                     let data = document.data()
                     let fieldValue = data["name"]
                     
                     self.waza.append(fieldValue as! String)
                 }
                 completed()
             }
         }
     }
    
    //set up screen
     override func viewWillAppear(_ animated: Bool) {
         createExerciseArray {
            self.tableView1.reloadData()
         }
         
         createWazaArray {
            self.tableView1.reloadData()
         }
     }
     override func viewDidLoad() {
         super.viewDidLoad()
          
           let settings = FirestoreSettings()
           Firestore.firestore().settings = settings
           db = Firestore.firestore()
 
           tableView1.delegate = self
           tableView1.dataSource = self

          self.count = 0
         
     }
    
    
    
    //table View Stuff
    // MARK: - Table view data source

    @IBOutlet weak var tableView1: UITableView!
    
       func numberOfSections(in tableView1: UITableView) -> Int {
         return 1
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return waza.count+exercise.count+2
     }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         //create a blank LibraryTableCell
           let cell =
               self.tableView1.dequeueReusableCell(withIdentifier:
               "wazaCell", for: indexPath)
                       as! LibraryTableViewCell
          
          DispatchQueue.main.async { //makes sure the cells are loaded in correct order
              //for the next waza.count+1 cells, set the label in the cell to waza name
              if(indexPath.row <= self.waza.count) {
                    if indexPath.row == 0 {
                        cell.wazaName.textAlignment = .center
                        cell.wazaName.text = "Uchikomi"
                        cell.wazaName.font = UIFont(name: "Baskerville-Bold", size: 30)
                        cell.plusSign.isHidden = true
                    }

                    else  {
                        cell.wazaName.text = self.waza[indexPath.row-1]
                        cell.wazaName.font = UIFont(name: "Baskerville", size: 20)
                        cell.wazaName.textAlignment = .left
                        cell.plusButton.addTarget(self, action: #selector(self.connected(sender:)), for: .touchUpInside)
                        cell.plusButton.tag = indexPath.row
                    }
                    //debugs ippon's lack of plus sign
                    if cell.wazaName.text == "Ippon Seionage" {
                        cell.plusSign.isHidden = false
                        cell.plusButton.isHidden = false
                    }
              }
                  
             //once all the elements in waza have a cell, set the following cells' labels to exercise element name
              else if indexPath.row > self.waza.count {
                  if indexPath.row == self.waza.count+1 {
                    cell.wazaName.text = "Exercises"
                    cell.wazaName.font = UIFont(name: "Baskerville-Bold", size: 30)
                    cell.wazaName.textAlignment = .center
                    cell.plusSign.isHidden = true
                  }
              
                  else {
                      //this 'if clause' prevents the count from going past the exercise array size and throwing an error
                      if(self.count == self.exercise.count) {
                          cell.wazaName.text = self.exercise[self.count-1]
                      }
                      else {
                        cell.wazaName.text = self.exercise[self.count]
                        cell.wazaName.font = UIFont(name: "Baskerville", size: 20)
                        cell.wazaName.textAlignment = .left
                        cell.plusButton.tag = indexPath.row
                        cell.plusButton.addTarget(self, action: #selector(self.connected(sender:)), for: .touchUpInside)
                          
                          self.count+=1
                      }
                  }
              }
          }
         return cell
     }
    
    
    //when button is clicked, use its tag to retrieve exercise name from one of the two arrays and store it in passName, which is then used in prepareForSegue
    var passedName = ""
    @objc func connected(sender: UIButton) {
        var buttonCount = sender.tag
        
        if buttonCount <= waza.count {
            let data = waza[sender.tag-1]
            passedName = data
            self.performSegue(withIdentifier: "LibraryToLog", sender: self)
        }
        else {
            buttonCount = sender.tag - waza.count
            let data = exercise[buttonCount-2]
            passedName = data
            self.performSegue(withIdentifier: "LibraryToLog", sender: self)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LibraryToLog" {
            let nextVC = segue.destination as! LogViewController
           
            nextVC.exerciseName = passedName
                if waza.contains(passedName) {
                    nextVC.isWaza = true
                }
                else {
                    nextVC.isWaza = false
                }
            nextVC.previousScreen = "Library"
        }
    }
    
    
}
