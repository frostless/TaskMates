//
//  profileSettingViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 18/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher

class profileSettingViewController: UIViewController {
    
    //Properties:
    
    var user:Users?
    
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var logOutBtn: UIButton!
    @IBAction func logOutBtnPressed(_ sender: Any) {
        //perform logout
        if Auth.auth().currentUser != nil {
            do {
                //clean up databse listeners
                cleanUpDatabaselisteners()
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfigure()
        buttonConfigure()
        loadUser()
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        
        if let id = Auth.auth().currentUser?.uid {
               Database.database().reference().child("Users").child(id).removeAllObservers()
        }

    }
    
    func cleanUpDatabaselisteners(){
        //clean up firebase db listeners
        Database.database().reference().child("Tasks").queryOrdered(byChild: "postedUser").queryEqual(toValue: Auth.auth().currentUser?.uid).removeAllObservers()
        Database.database().reference().child("Tasks").removeAllObservers()
        if let id = Auth.auth().currentUser?.uid {
            Database.database().reference().child("Users").child(id).removeAllObservers()
            
        }
        
        if let messages = self.user?.messages {
            for ( _, msgID) in messages{
                let msgRef =  Database.database().reference().child("Messages").child(msgID)
                msgRef.removeAllObservers()
            }
        }
    }
    
    //Loading
    
    func loadUser(){
        
        let userRef =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                 self.user = Users(dictionary: dictionary)
                
            }
            
            self.tableView.reloadData()
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

    //UI
    func tableViewConfigure(){
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func buttonConfigure(){
        
        logOutBtn.layer.cornerRadius = 10
        logOutBtn.layer.borderWidth = 1
        logOutBtn.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let navVC = segue.destination as? UINavigationController
        if segue.identifier == "toProfileChanging" {
            let destinationViewController = navVC?.viewControllers.first as! detailsChangingViewController
            destinationViewController.user = user
            
        }
    }
    
    
    //backSegue
    
    @IBAction func backToProfileSetting(segue:UIStoryboardSegue) {
        tableView.reloadData()
    }
    
}

extension profileSettingViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! customProfileCell
            
            if let user = user {
                if user.profilePhotoUrl != "" {
                    
                    let imgUrl = URL(string: (user.profilePhotoUrl))
                    cell.profileImg.kf.setImage(with: imgUrl)
                } else {
                    cell.profileImg.image = UIImage(named:"profilePhoto")
                }
                
            }
            
            cell.profileImg.translatesAutoresizingMaskIntoConstraints = true
            cell.profileImg.layer.cornerRadius = 15
            cell.profileImg.layer.masksToBounds = true
            
            cell.nameLabel.text = user?.displayName
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "skillsCell", for: indexPath) as! customSkillsCell
            
            cell.skillsImg.image = UIImage(named:"skills")
            cell.skillslabel.text = "技能"
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "languagesCell", for: indexPath) as! customLanguagesCell
            
            cell.languagesImg.image = UIImage(named:"languages")
            cell.languagesLabel.text = "语言"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //only perform segue when user is loaded~
        if let _ = user {
            if indexPath.section == 0 {
                performSegue(withIdentifier: "toProfileChanging", sender: self)
                
            } else if indexPath.section == 1 {
                performSegue(withIdentifier: "toProfileChanging", sender: self)
                
            } else {
                
                performSegue(withIdentifier: "toProfileChanging", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = UIColor.gray
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //delete the extra footer view
    func tableView
        (_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    
}

class customProfileCell:UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}

class customSkillsCell:UITableViewCell {
    
    @IBOutlet weak var skillsImg: UIImageView!
    @IBOutlet weak var skillslabel: UILabel!
    
    
}

class customLanguagesCell:UITableViewCell {
    @IBOutlet weak var languagesImg: UIImageView!
    @IBOutlet weak var languagesLabel: UILabel!
}
