//
//  taskerDetailsAndOfferAcceptViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 27/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase

class taskerDetailsAndOfferAcceptViewController: UIViewController,UITextFieldDelegate {
    
    //MARK: properties
    var task:Tasks?
    var user:Users? // the offered user that was tapped from last
    var offeredUsers:[Users]?
    var visitingUser:Users? //visitingTasker
    var reviews = [Reviews]()
    
    var ratingControle:RatingControl?
    
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
    @IBOutlet weak var acceptOffer: UIButton!
    
    //for writing review
    var textField:UITextField?
    var editingView:UIView?
    var seperaterView:UIView?
    var changeButton:UIButton?
    
    
    @IBAction func acceptOfferBtnPressed(_ sender: Any) {
 
        if task?.assignedTasker != "" {
             showAlert(withTitle: "粗错了", message: "这个任务已经接受过报价了!")
            return
        }
        
        if let offeredUsers = offeredUsers,let visitingUser = visitingUser,let task = self.task, let user = self.user {
            
            showAlert(withTitle: "提示", message: "成功接受报价!")
            
             let msgRef = Database.database().reference().child("Messages")
             let userRef = Database.database().reference().child("Users")
            
            if let messageRef = visitingUser.messages[user.id]{
                //send messages to offeredUser and taskPoster
                //existing conversation
                let id = messageRef
                let msgID = msgRef.child(id).childByAutoId().key
                let timeStamp = String(NSDate().timeIntervalSince1970)
                let messageToBeStore = [
                    "sender": visitingUser.id,
                    "receiver": user.id,
                    "timeStamp":timeStamp,
                    "content": "我接受了你对于任务\"\(task.title)\"的报价",
                    "id":msgID,
                    "belongedID":id
                ]
                 msgRef.child(id).child(msgID).setValue(messageToBeStore)
                
            } else {
//                conversation not existed
                let id = msgRef.childByAutoId().key
                let msgID = msgRef.child(id).childByAutoId().key
                let timeStamp = String(NSDate().timeIntervalSince1970)
                
                let messageToBeStore = [
                    "sender": visitingUser.id,
                    "receiver": user.id,
                    "timeStamp":timeStamp,
                    "content": "我接受了你对于任务\"\(task.title)\"的报价!",
                    "id":msgID,
                    "belongedID":id
                ]
                
                msgRef.child(id).child(msgID).setValue(messageToBeStore)
                userRef.child(visitingUser.id).child("messages").child(user.id).setValue(id)
                userRef.child(user.id).child("messages").child(visitingUser.id).setValue(id)
                
                self.visitingUser?.messages[user.id] = id
                self.user?.messages[visitingUser.id] = id
               
            }
         
            for offeredUser in offeredUsers {
                //send messages to all involved parties
                if offeredUser == user{
                    continue
                }
                if let messageRef = visitingUser.messages[offeredUser.id]{
                    //send messages to offeredUser and taskPoster
                    //existing conversation
                    let id = messageRef
                    let msgID = msgRef.child(id).childByAutoId().key
                    let timeStamp = String(NSDate().timeIntervalSince1970)
                    let messageToBeStore = [
                        "sender": visitingUser.id,
                        "receiver": offeredUser.id,
                        "timeStamp":timeStamp,
                        "content": "很抱歉，你竞标的任务\"\(task.title)\"已经被其他人竞标成功了...",
                        "id":msgID,
                        "belongedID":id
                    ]
                    msgRef.child(id).child(msgID).setValue(messageToBeStore)
                } else {
                    //conversation not existed
                    let id = msgRef.childByAutoId().key
                    let msgID = msgRef.child(id).childByAutoId().key
                    let timeStamp = String(NSDate().timeIntervalSince1970)
                    
                    let messageToBeStore = [
                        "sender": visitingUser.id,
                        "receiver": user.id,
                        "timeStamp":timeStamp,
                        "content": "很抱歉，你竞标的任务\"\(task.title)\"已经被其他人竞标成功了...",
                        "id":msgID,
                        "id":msgID,
                        "belongedID":id
                    ]
                    
                    msgRef.child(id).child(msgID).setValue(messageToBeStore)
                    userRef.child(visitingUser.id).child("messages").child(offeredUser.id).setValue(id)
                    userRef.child(offeredUser.id).child("messages").child(visitingUser.id).setValue(id)
                    
                    self.visitingUser?.messages[offeredUser.id] = id
                    self.visitingUser?.acceptedTasks.append(task.id)
                    offeredUser.messages[visitingUser.id] = id
                }
            }
            
            //update task
           Database.database().reference().child("Tasks").child(task.id).child("assignedTasker").setValue(user.id)
            
             task.assignedTasker = user.id//prevent double acceptance
            
            //update Users
            
 Database.database().reference().child("Users").child(user.id).child("acceptedTasks").child((self.task?.id)!).setValue(true)
            
            user.acceptedTasks.append(task.id)
        }

    }
    

    @IBAction func sendMsgBtnPressed(_ sender: Any) {
        
                if user?.id == Auth.auth().currentUser?.uid {
                    showAlert(withTitle: "粗错了...", message: "自己不能跟自己发消息")
                } else {
        //perform segue programmatically  too far away in storyboard
                    guard let  msgDetailsViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "messageDetails") as? msgDetailsViewController else {
                        return
                    }
                    msgDetailsViewController.msgReceiver = user
                    msgDetailsViewController.msgSender = visitingUser
                    let backItem = UIBarButtonItem()
                    backItem.title = "后退"
                    navigationItem.backBarButtonItem = backItem
                    self.navigationController?.pushViewController( msgDetailsViewController, animated:true)
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
        
        acceptOffer.layer.cornerRadius = 10
        acceptOffer.layer.borderWidth = 1
        acceptOffer.layer.borderColor = UIColor.gray.cgColor

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
        taskerRatingImg.isUserInteractionEnabled = true
        taskerRatingImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ratingImgTapped)))
       
        
        postedTasksNumber.text = "任务数:\(String(describing: (user?.postedTasks.count)!))"
        offeredTasksNumber.text = "竞标数:\(String(describing: (user?.offeredTasks.count)!))"
        finishedTasksNumber.text = "接受数:\(String(describing: (user?.acceptedTasks.count)!))"
        
        tasksPosterImg.image = UIImage(named: "posted")
        tasksSolverImg.image = UIImage(named: "bidded")
        goodRatingImg.image = UIImage(named: "accepted")

    }

    @objc func saveRating(){
        guard let ratingControle = ratingControle else {
            return
        }
        
        guard let id = user?.id, let visitingID = visitingUser?.id,let taskID = task?.id else {
            return
        }
        
        let userRef = Database.database().reference().child("Users").child(id)
        let rating = user?.rating[String(ratingControle.rating)] ==
            nil ? 0 : user?.rating[String(ratingControle.rating)]
     //upadate database
        userRef.child("rating").child(String(ratingControle.rating)).setValue(rating! + 1)
        userRef.child("ratingUsers").child(taskID).setValue(visitingID)
    //update user
        user?.rating[String(ratingControle.rating)] = rating! + 1
        user?.ratingUsers[taskID] = visitingID
        
        showAlert(withTitle: "提示", message: "本次打分已保存！")
        ratingControle.removeFromSuperview()
        taskerRatingImg.isHidden = false
        self.navigationItem.rightBarButtonItem = nil
        
    }
    
    @objc func ratingImgTapped(){
        
        if task?.assignedTasker != user?.id {
            showAlert(withTitle: "粗错了", message: "你只能给成功竞标了你的任务的用户打分")
            return
        }
        
        if let ratingUsers = user?.ratingUsers {
            for (_,tasker) in ratingUsers {
                if tasker == visitingUser?.id {
                showAlert(withTitle: "粗错了", message: "你已经完成对这名用户的打分")
                return
                }
            }
        }
        
        if let dueDate = task?.dueDate {
            if Date() < dueDate {
                showAlert(withTitle: "粗错了", message: "必须在任务截止后才能进行打分")
                return
            }
        }
        
        guard let parentView = taskerRatingImg.superview else {
            return
        }
        //
        taskerRatingImg.isHidden = true
        //
        ratingControle = RatingControl()
        ratingControle?.axis = .horizontal
        ratingControle?.distribution = .fillEqually
        ratingControle?.alignment = .fill
        ratingControle?.spacing = 8
        ratingControle?.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addSubview(ratingControle!)
        
        ratingControle?.frame = taskerRatingImg.frame
        
        ratingControle?.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        ratingControle?.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
        
        //setup baritem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "打分", style: .plain, target: self, action: #selector(saveRating))

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
    

    
    @objc func writeReview(){
        
        guard let textFieldText = textField?.text else {
            return
        }
        
            let reviewRef = Database.database().reference().child("Reviews")
            let id = reviewRef.childByAutoId().key
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
            
            let createdTime = formatter.string(from: Date())
        
        guard let toID = self.user?.id, let fromID = visitingUser?.id, let taskID = self.task?.id else {
            return
        }
            let reviewToBeStored = [
                "toID":toID,
                "fromID":fromID,
                "id":id,
                "taskID":taskID,
                "createdTime": createdTime,
                "content":textFieldText
            ]
        
        let review = Reviews(toID,fromID,textFieldText,id,taskID,Date())
            //upload reviews firebase
            reviewRef.child(id).setValue(reviewToBeStored)
           //update local reviews array
        if reviews.count == 0 {
            reviews.append(review)
            self.tableView.reloadData() //do this manually in case the observer is inactive
        }
            let userRef = Database.database().reference().child("Users").child(toID)
            userRef.child("reviews").child(fromID).setValue(id)
            //update user
            user?.reviews["\(fromID)"] = id
            textField?.text = nil
            deleteFooterView()
            self.tableView.scrollToBottomWhenReviewUpdated()

    }
    
    func showEditingView(){
    deleteFooterView()
    
    self.tableView.scrollToBottomWhenReviewUpdated()
    
    editingView = UIView(frame: CGRect(x: 0, y: self.view.frame.height-56 , width: self.view.frame.width, height: 56))
    editingView?.backgroundColor = UIColor.groupTableViewBackground
    
    
    seperaterView = UIView(frame: CGRect(x: 0, y: self.view.frame.height-57 , width: self.view.frame.width, height: 1))
    seperaterView?.backgroundColor = .black
    
    changeButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 8, width: 44.00, height: 44.00));
    changeButton?.setTitle("确定", for: .normal)
    changeButton?.layer.cornerRadius = 10
    changeButton?.layer.borderWidth = 1
    changeButton?.backgroundColor = .white
    
    let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    changeButton?.layer.borderColor = borderColor.cgColor
    changeButton?.setTitleColor(UIColor.blue, for:UIControlState.normal)
    
    changeButton?.addTarget(self, action: #selector(writeReview), for: .touchUpInside)
    
    textField = TextField(frame: CGRect(x: 8, y: 8, width: self.view.frame.width - 64, height: 44.00));
    textField?.textAlignment = NSTextAlignment.left
    editingView?.addSubview(textField!)
    
    textField?.placeholder = "我要写评论"
    textField?.backgroundColor = .white
    textField?.delegate = self
    
    textField?.layer.cornerRadius = 10
    textField?.layer.borderWidth = 1
    textField?.layer.borderColor = borderColor.cgColor
    
    editingView?.addSubview(textField!)
    editingView?.addSubview(changeButton!)
    
    self.view.addSubview(seperaterView!)
    self.view.addSubview(editingView!)
    }
    
    func deleteFooterView(){
        
        if let textField =  textField {
            textField.removeFromSuperview()
        }
        
        
        if let changeButton = changeButton {
            
            changeButton.removeFromSuperview()
        }
        
        
        if let editingView = editingView {
            editingView.removeFromSuperview()
        }
        
        if let seperaterView =  seperaterView {
            
            seperaterView.removeFromSuperview()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //??
        textField.resignFirstResponder()
        return true
    }
    
}


extension taskerDetailsAndOfferAcceptViewController: UITableViewDataSource,UITableViewDelegate {
    
    
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
                 cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这位用户目前没有登记任何技能").width + 17
                cell.skillLabel.text = "这位用户目前没有登记任何技能"
                
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
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这位用户目前没有登记任何语言").width + 18
                cell.languageLabel.text = "这位用户目前没有登记任何语言"
                
            } else {
                
                let language = user?.languages[indexPath.row]
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: language!).width + 17
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
                
                setupNameAndImageProfile(review:review,cell:cell)//setup name and image from extension
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            //conditional check if review has been made
            if let user = self.user,let visitingUser = self.visitingUser {
                for(key,_) in user.reviews {
                    if key == visitingUser.id {
                        showAlert(withTitle: "粗错了", message: "你已经评价过此用户")
                        return
                    }
                }
            }
            
            if user?.id == task?.assignedTasker {
                if let dueDate = task?.dueDate {
                    if Date() < dueDate {
                        showAlert(withTitle: "粗错了", message: "必须在任务截止后才能进行评价")
                        return
                    }
                }
                
                showEditingView()//display editing footerView
            } else {
              showAlert(withTitle: "粗错了", message: "你只能对竞标成功了你的任务的用户进行评价")
            }
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


