//
//  taskerDetailViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 14/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase

class taskerDetailViewController: UIViewController {
    
    //MARK: properties
    var user:Users? //taskPoster
    var visitingUser:Users? //visitingTasker
    var reviews = [Reviews]()
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskerProfileImg: UIImageView!
    @IBOutlet weak var taskerDisplayName: UILabel!
    @IBOutlet weak var taskerJoinedTime: UILabel!
    @IBOutlet weak var taskerRatingImg: UIImageView!
    @IBOutlet weak var tasksPosterImg: UIImageView!
    @IBOutlet weak var tasksSolverImg: UIImageView!
    @IBOutlet weak var goodRatingImg: UIImageView!
    @IBOutlet weak var postedTasksNumber: UILabel!
    @IBOutlet weak var offeredTasksNumber: UILabel!
    @IBOutlet weak var finishedTasksNumber: UILabel!
    @IBOutlet weak var sendMsgBtn: UIButton!
    
    @IBAction func sendMsgBtnPressed(_ sender: Any) {
        if user?.id == Auth.auth().currentUser?.uid {
            showAlert(withTitle: "粗错了...", message: "自己不能跟自己发消息")
        } else {
            
            performSegue(withIdentifier: "taskerDetailsToMsg", sender: self)
        }
      
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfigure()
        UIconfigue()
        buttonConfigure()
        loadReviews()
        
    }
    
    
    // this is to make tableview headerview self-sizing
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
        
    }
    
    
    //MARK:configure
    
    func tableViewConfigure(){
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
    }
    
    func buttonConfigure(){
        //button configuration
        //waitingTobeAccepted.backgroundColor = .clear
        sendMsgBtn.layer.cornerRadius = 10
        sendMsgBtn.layer.borderWidth = 1
        sendMsgBtn.layer.borderColor = UIColor.gray.cgColor
    }
    
    func UIconfigue(){
        
        //tasker configure
        if user?.profilePhotoUrl != "" {
            let imgUrl = URL(string: (user?.profilePhotoUrl)!)
            taskerProfileImg.kf.setImage(with: imgUrl)
        } else {
            
            taskerProfileImg.image = UIImage(named:"profilePhoto")
        }
        
        taskerProfileImg.translatesAutoresizingMaskIntoConstraints = true
        taskerProfileImg.layer.cornerRadius = 30
        taskerProfileImg.layer.masksToBounds = true
        
        
        taskerDisplayName.text = user?.displayName
        taskerJoinedTime.text = "注册于:\(timeAgoSinceDate((user?.sinceTime)!))"
        
        //rating images
        if user?.aveRating == 5{
            taskerRatingImg.image = UIImage(named:"5 star rating")
        } else if user?.aveRating == 4 {
            taskerRatingImg.image = UIImage(named:"4 star rating")
        } else if user?.aveRating == 3 {
            taskerRatingImg.image = UIImage(named:"3 star rating")
        } else if user?.aveRating == 2 {
            taskerRatingImg.image = UIImage(named:"2 star rating")
        } else if user?.aveRating == 1 {
            taskerRatingImg.image = UIImage(named:"1 star rating")
        } else {
            taskerRatingImg.image = UIImage(named:"0 star rating")
        }
        
        postedTasksNumber.text = "任务数:\(String(describing: (user?.postedTasks.count)!))"
        offeredTasksNumber.text = "竞标数:\(String(describing: (user?.offeredTasks.count)!))"
        finishedTasksNumber.text = "接受数:\(String(describing: (user?.acceptedTasks.count)!))"
        
        tasksPosterImg.image = UIImage(named: "posted")
        tasksSolverImg.image = UIImage(named: "bidded")
        goodRatingImg.image = UIImage(named: "accepted")
        
        let block = UIBarButtonItem(title: "屏蔽用户", style: .plain, target: self, action: #selector(blockUser))
        
        navigationItem.rightBarButtonItems = [block]
        
    }
    
    @objc func blockUser() {
        
        if user?.id == Auth.auth().currentUser?.uid {
            showAlert(withTitle: "粗错了...", message: "不能屏蔽自己")
            return
        }
        let alertController = UIAlertController(title: "请求确认", message: "您确认要屏蔽这个用户吗？屏蔽后将看不到该用户发布的任务和聊天信息", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "确定", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            //class Users is reference type,change here will reflect in all tasks
            if self.visitingUser?.blockedUsers == nil {
                self.visitingUser?.blockedUsers = [(self.user?.id)!]
            } else {
                self.visitingUser?.blockedUsers?.append((self.user?.id)!)
            }
            
            Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("blockedUsers").setValue(self.visitingUser?.blockedUsers)
            //remove db observers
            let parentVC = self.parent?.childViewControllers[0] as! taskDetailViewController
            parentVC.removeFireBaseObserver()
            
            self.dismiss(animated: true, completion: {
                let window = UIApplication.shared.keyWindow
                //                let vc = window?.currentViewController()?.childViewControllers[2].childViewControllers[0] as! allTasksViewController
                //                vc.loadFirTasks()
                //refresh the detail view
                let detailVC = window?.currentViewController()?.childViewControllers[4].childViewControllers[0] as! profileSettingViewController
                //only call when vc has been loaded
                if detailVC.isViewLoaded {
                    detailVC.loadUser()
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    //load Reviews
    
    func loadReviews(){
        
        if user?.reviews.count == 0 {
            return
        }
        
        let reviewRef = Database.database().reference().child("Reviews")
        
        for (_,val) in (user?.reviews)! {
            
            reviewRef.child(val).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
                let review = Reviews(dictionary: dictionary)
                self.reviews.append(review)
                self.tableView.reloadData()
            })
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskerDetailsToMsg" {
            if let msgDetailsViewController = segue.destination as? msgDetailsViewController {
                msgDetailsViewController.msgReceiver = user
                msgDetailsViewController.msgSender = visitingUser
                let backItem = UIBarButtonItem()
                backItem.title = "后退"
                navigationItem.backBarButtonItem = backItem
                
            }
            
        }
    }
    
}

extension taskerDetailViewController: UITableViewDataSource,UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            if user?.skills.count == 0 {
                return 1
            } else {
                return (user?.skills.count)!
            }
        } else if section == 1 {
            if user?.languages.count == 0 {
                return 1
            } else {
                return (user?.languages.count)!
            }
        }else if section == 2 {
            return 1
        } else {
            if reviews.count == 0 {
                return 1
            } else {
                return reviews.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "skillsCell", for: indexPath) as? skillsChangingCell  else {
                fatalError("error happended during dequeue")
            }
            if user?.skills.count == 0 {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这名用户暂时没有提供任何技能").width + 17 //different from other cells
                cell.skillLabel.text = "这名用户暂时没有提供任何技能"
                
            } else {
                
                let skill = user?.skills[indexPath.row]
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: skill!).width + 17 //different from other cells
                cell.skillLabel.text = skill
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "languagesCell", for: indexPath) as? languagesChangingCell  else {
                fatalError("error happended during dequeue.")
            }
            if user?.languages.count == 0 {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这名用户暂时没有提供任何语言").width + 18
                cell.languageLabel.text = "这名用户暂时没有提供任何语言"
                
            } else {
                let language = user?.languages[indexPath.row]
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: language!).width + 18
                cell.languageLabel.text = language
            }
            
            return cell
        } else if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? descriptionChangingCell  else {
                fatalError("error happended during dequeue.")
            }
            if user?.selfDescription == "" {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这名用户暂时没有提供任何自我描述").width + 18
                cell.descriptionLabel.text = "这名用户暂时没有提供任何自我描述"
            } else {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: (user?.selfDescription)!).width + 18
                cell.descriptionLabel.text = user?.selfDescription
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as? reviewsToTaskerCell  else {
                fatalError("error happended during dequeue.")
            }
            
            if reviews.count == 0 {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "目前暂时没有关于这名用户的评论").width + 18
                cell.reviewLabel.text = "目前暂时没有关于这名用户的评论"
            } else {
                let review = reviews[indexPath.row]
                cell.bubbleWidthAnchor?.constant = estimateFrameForReviewBubble(text:review.content!
                    ).width + 18
                cell.reviewLabel.text = review.content
                if let createdTime = review.createdTime {
                    cell.timeLabel.text = timeAgoSinceDate(createdTime)
                }
                //extension function
                setupNameAndImageProfile(review:review,cell:cell)//setup name and image
            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "技能"
            return headerText
        } else  if section == 1 {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "语言"
            return headerText
        } else if section == 2 {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "自我描述"
            return headerText
        } else {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "评论"
            return headerText
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    //delete the extra footer view
    func tableView
        (_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    
}

