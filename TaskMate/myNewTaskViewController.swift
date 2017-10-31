//
//  myNewTaskViewController.swift
//  TaskMate
//
//  Created by Zheng Wei on 6/2/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import MapKit
import Firebase


class myNewTaskViewController: UIViewController {
    

    //PROPERTIES:
     var task: Tasks?
    //var tasks = [Tasks]()
    var comments:[Comments] = []
//    var commentedUsers:[Users] = []
    var offers: [Offers] = []
    var offeredUsers:[Users] = []
    var user: Users?//app visitor
    var taskPoster:Users?//poster
    var replies = Comments("comment")
    
    var shouldTableViewReload:Bool?
     //IB Outlests
    
    @IBOutlet weak var commentsField: UITextView!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapV: MKMapView!
    @IBOutlet weak var taskDescription: UILabel!
    @IBOutlet weak var taskerName: UILabel!
    @IBOutlet weak var taskDescriptionView: UIView!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var waitingTobeAccepted: UIButton!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var taskBudget: UILabel!
    @IBOutlet weak var createdDay: UILabel!
    @IBOutlet weak var taskAddressImg: UIImageView!
    @IBOutlet weak var taskDueDateImg: UIImageView!
    @IBOutlet weak var taskBudgetImg: UIImageView!
     
    
    @IBAction func backButtonPressed(_ sender: Any) {
        removeFireBaseObserver()
        performSegue(withIdentifier: "backToMyTasks", sender: self)
    }
    
    func removeFireBaseObserver(){
        let offersRef = Database.database().reference().child("Tasks").child((task?.id)!).child("offeredUsers")
        offersRef.removeAllObservers()
        let commentsRef = Database.database().reference().child("Comments").child((task?.commentsID)!)
        commentsRef.removeAllObservers()
    }
 
    
    @IBAction func userOptionsButton(_ sender: Any, forEvent event: UIEvent) {
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "复制", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc: newTasksViewController = mainStoryboard.instantiateViewController(withIdentifier: "newTaskEntry") as! newTasksViewController
            //completion block extension
            self.navigationController!.pushViewController(viewController: vc, animated: true){
                vc.taskTitle.text = self.task?.title
                vc.taskDescription.text = self.task?.desc
                //exit to remove database observer
                self.removeFireBaseObserver()
            }
        })
        
        let shareAction = UIAlertAction(title: "分享", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let screen = UIScreen.main
            
            if let window = UIApplication.shared.keyWindow {
                UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
                let image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                let imageObject=WXImageObject()
                imageObject.imageData=UIImagePNGRepresentation(image!)
                
                let message=WXMediaMessage()
                message.title=nil
                message.description=nil
                message.mediaObject=imageObject
                message.mediaTagName="MyPic"
                //图片缩略图
                let width = 240.0 as CGFloat
                let height = width*image!.size.height/image!.size.width
                
                UIGraphicsBeginImageContext(CGSize(width: width, height: height))
                image!.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                message.setThumbImage(UIGraphicsGetImageFromCurrentImageContext())
                UIGraphicsEndImageContext()
                
                let req=SendMessageToWXReq()
                req.text=nil
                req.message=message
                req.bText=false
                req.scene=1
                WXApi.send(req)
                
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:nil)
        
        
        optionMenu.addAction(saveAction)
        optionMenu.addAction(shareAction)
        optionMenu.addAction(cancelAction)
        //for ipad
        if let popoverPresentationController = optionMenu.popoverPresentationController {
            
            if let touch = event.touches(for: sender as! UIView)?.first{
                // print the touch location on the button
                let locationX = touch.location(in: self.view).x
                let locationY = touch.location(in: self.view).y
                
                popoverPresentationController.sourceView = self.view
                optionMenu.popoverPresentationController?.sourceRect = CGRect(x: locationX, y: locationY, width: 1.0, height: 1.0)
                self.present(optionMenu, animated: true, completion: nil)
                return
                
            }
        }
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func deleteButtonPressed(_ sender: Any, forEvent event: UIEvent) {
        
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
                let deleteAction = UIAlertAction(title: "删除", style: .destructive, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.showAlertWithCompletionHandler(withTitle: "提示", message: "任务删除成功")
                                let id = self.task?.id
                                Database.database().reference().child("Tasks").child(id!).setValue(nil)
                    if self.task?.commentsID != ""{
                        //delete related comments
                        Database.database().reference().child("Comments").child((self.task?.commentsID)!).setValue(nil)
                    }
                })
               let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:nil)
        
                  optionMenu.addAction(deleteAction)
                  optionMenu.addAction(cancelAction)
        //for ipad
        if let popoverPresentationController = optionMenu.popoverPresentationController {
            
            if let touch = event.touches(for: sender as! UIView)?.first{
                // print the touch location on the button
                let locationX = touch.location(in: self.view).x
                let locationY = touch.location(in: self.view).y
                
                popoverPresentationController.sourceView = self.view
                optionMenu.popoverPresentationController?.sourceRect = CGRect(x: locationX, y: locationY, width: 1.0, height: 1.0)
                self.present(optionMenu, animated: true, completion: nil)
                return
                
            }
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
   
    
    @IBAction func addComment(_ sender: Any) {
        
        if commentsField.text != "" && commentsField.text != "我要评论" {
            
            let taskRef = Database.database().reference().child("Tasks")
            let commentRef = Database.database().reference().child("Comments")
            
            let id = self.task?.id
            let key = commentRef.childByAutoId().key
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
            let createdTime = formatter.string(from: Date())
            
            
            if (task?.commentsID)! == "nil" {
                taskRef.child(id!).child("commentsID").setValue(key)
                task?.commentsID = key
                let commentKey = commentRef.child(key).childByAutoId().key
                
                let commentToBeStored = [
                    "id":commentKey,
                    "content": commentsField.text!,
                    "createdTime": createdTime,
                    "belongedTask":self.task?.id,
                    "commentedTaskerName":self.user?.displayName,
                    "commentedTaskerProfileUrl":self.user?.profilePhotoUrl,
                    "commentedTaskerID":Auth.auth().currentUser?.uid
                ]
                
                commentRef.child(key).child(commentKey).setValue(commentToBeStored)
                loadComments()
            } else {
                
                let commentKey = commentRef.child(key).childByAutoId().key
                let commentToBeStored = [
                    "id":commentKey,
                    "content": commentsField.text!,
                    "createdTime": createdTime,
                    "belongedTask":self.task?.id,
                    "commentedTaskerName":self.user?.displayName,
                    "commentedTaskerProfileUrl":self.user?.profilePhotoUrl,
                    "commentedTaskerID":Auth.auth().currentUser?.uid
                ]
                
                commentRef.child((task?.commentsID)!).child(commentKey).setValue(commentToBeStored)
            }
            //moved to function load comments
            //commentsField.text = ""
        }

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskDetailConfigure()
        taskDescriptionViewConfigure()
        mapConfigure()
        buttonConfigure()
        tableViewConfigure()
        keyboardConfigure()
        
        loadComments()
        loadOffers()
        loadUser()
        loadTaskPoster()
  
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
        
        guard let footerView = tableView.tableFooterView else {
            return
        }
        let footerViewSize = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        if footerView.frame.size.height != footerViewSize.height {
            footerView.frame.size.height = footerViewSize.height
            tableView.tableFooterView = footerView
            tableView.layoutIfNeeded()
        }
    }
    
 
//    func profileImgSegueToTaskerDetails(){
//        
//        self.performSegue(withIdentifier: "profileImgToTaskerDetails", sender: self)
//        
//        
//    }
    
    //UI configuration
    
    func taskDetailConfigure(){
        taskTitle.text = task?.title
        taskDescription.text = task?.desc
        
        //comment textView
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        commentsField.layer.borderWidth = 0.5
        commentsField.layer.borderColor = borderColor.cgColor
        commentsField.layer.cornerRadius = 5.0
        commentsField.text = "我要评论"
        commentsField.textColor = UIColor.lightGray
        
        
        userProfileImg.translatesAutoresizingMaskIntoConstraints = true
        userProfileImg.layer.cornerRadius = 24
        userProfileImg.layer.masksToBounds = true
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImgSegueToTaskerDetails))
//        userProfileImg.addGestureRecognizer(tapGesture)
        
        taskAddressImg.image = UIImage(named: "taskAddress")
        taskDueDateImg.image = UIImage(named:"taskTimer")
        taskBudgetImg.image = UIImage(named:"budget")
        
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        dueDate.text = formatter.string(from:task!.dueDate)
        
        taskLocation.text = task?.location
        taskBudget.text = "$" + String(describing: task!.budget)
        //time elasped
        createdDay.text = timeAgoSinceDate((task?.createdDate)!)
        
        //upload user profile photo
        if task?.imageURL != "" {
            let imgUrl = URL(string: (task?.imageURL)!)
            userProfileImg.kf.setImage(with: imgUrl)
        } else {
            userProfileImg.image = UIImage(named:"profilePhoto")
        }
        
    }
    
    
    func keyboardConfigure(){
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    func taskDescriptionViewConfigure(){
        //taskPriceView configuration
        taskDescriptionView.layer.borderWidth = 1
        taskDescriptionView.layer.cornerRadius = 10
        taskDescriptionView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func mapConfigure(){
        
        //map configuration
        mapV.delegate = self
        
        mapV.showsUserLocation = true
        let location = mapV.userLocation.coordinate
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapV.setRegion(region, animated: true)
        
    }
    
    func buttonConfigure(){
        //button configuration
        //waitingTobeAccepted.backgroundColor = .clear
        waitingTobeAccepted.layer.cornerRadius = 10
        waitingTobeAccepted.layer.borderWidth = 1
        waitingTobeAccepted.layer.borderColor = UIColor.gray.cgColor
    }
    
    func tableViewConfigure(){
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
    }
    
    //loading data from firebase
    
    func loadComments() {
        
        guard let taskID = task?.commentsID else {
            print("this task has no comments")
            return
        }
        
            let commentsRef = Database.database().reference().child("Comments").child(taskID)
            
            commentsRef.observe(DataEventType.value, with: {(snapshot) in
                // do nothing when the likes inrement
                if self.shouldTableViewReload != nil {
                    self.shouldTableViewReload = nil
                    return
                }
                
                if snapshot.exists() {
                    
                    self.comments.removeAll()
                 
                    for comments in snapshot.children.allObjects as![DataSnapshot] {
                        if let dictionary = comments.value as? [String:AnyObject] {
                            let comment = Comments(dictionary:dictionary,task:self.task!)
                            
                            if let commentsRepliesDic = dictionary["replies"] {
                                let rep = commentsRepliesDic as! Dictionary<String, AnyObject> as Dictionary
                                for ( _, val) in rep {
                                    guard let replies = val as? [String:AnyObject] else {
                                        return
                                    }
                                    let commentReplies = Comments(dic:replies,task:self.task!)
                                    //                                // for right order
                                    //                                comment.replies.insert(commentReplies, at: 0)
                                   comment.replies.append(commentReplies)
                                }
                            }
                               self.comments.append(comment)
                        }

                    }
                    
                    self.tableView.reloadData() 
                    //populate the commentsUsers[]
//                    self.loadCommentsUsers()
                    
                }
                
                if self.commentsField.text != "我要评论" {
                    self.tableView.scrollToBottom()
                }
                self.commentsField.text = "我要评论"
                self.commentsField.textColor = UIColor.lightGray
            })
        
    }
    
    func loadOffers(){
        
        let offersRef = Database.database().reference().child("Tasks").child((task?.id)!).child("offeredUsers")
        
        offersRef.observe(DataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0{
                self.offers.removeAll()
                
                for offers in snapshot.children.allObjects as![DataSnapshot] {
                    guard let dictionary = offers.value as? [String:String] else {
                        return
                    }
                     let offer = Offers(dictionary:dictionary)
                    self.offers.append(offer)
                }
            }
//            self.tableView.reloadData()
            //populate the offered users[]
//            self.loadOfferedUsers() do it in offer cell
        })
        
    }
    
    func loadTaskPoster(){
        let userRef =  Database.database().reference().child("Users").child((task?.postedUser)!)
        
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                self.taskPoster = Users(dictionary:dictionary)
            }

        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    func loadUser(){
        
        let userRef =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
        
            if let dictionary = snapshot.value as? [String:AnyObject] {
                 self.user = Users(dictionary:dictionary)
                //setup tasker name
                self.taskerName.text = self.user?.displayName
            }
    
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    //Mark:Load Users[] for offers
    
//    func loadOfferedUsers(){
//
//        if offers.count > 0 {
//
//            for offer in offers {
//
//                let userRef =  Database.database().reference().child("Users").child(offer.offeredTakserID)
//
//                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
//
//                    if let dictionary = snapshot.value as? [String:AnyObject] {
//                        let user = Users(dictionary:dictionary)
//                        self.offeredUsers.append(user)
//                    }
//                     self.tableView.reloadData()
//                })
//
//            }
//        }
//    }
    
    //Mark:Load Users[] for comments
//    func loadCommentsUsers(){
//
//        if comments.count > 0 {
//
//            //append replies users to the users[]
//
//            var commentsInThisBlock = self.comments
//
//            for repliesComments in commentsInThisBlock {
//
//                if repliesComments.replies.count != 0 {
//
//                    for com in repliesComments.replies {
//
//                        commentsInThisBlock.append(com)
//                    }
//
//                }
//
//            }
//
//            for comment in commentsInThisBlock {
//
//                let userRef =  Database.database().reference().child("Users").child(comment.commentedTaskerID)
//
//                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                    //                    self.commentedUsers.removeAll()
//                    if let dictionary = snapshot.value as? [String:AnyObject] {
//                        let user = Users(dictionary:dictionary)
//                        self.commentedUsers.append(user)
//                    }
////                    self.tableView.reloadData()
//                    // ...
//                }) { (error) in
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
    
    
    func showAlertWithCompletionHandler(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "确定", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "myTasktoCommentReply" {
            if let commentReplyViewController = segue.destination as? commentReplyViewController {
                commentReplyViewController.comment = sender as? Comments
                commentReplyViewController.id = task!.commentsID
                commentReplyViewController.user = self.user
            }
        }
        if segue.identifier == "myTaskCommentsToTaskerDetails" {
            if let taskerDetailViewController = segue.destination as? taskerDetailViewController {
                taskerDetailViewController.user = sender as? Users
                taskerDetailViewController.visitingUser = self.user
            }
        }
        
        if segue.identifier == "myTaskOffersToTaskerDetails" {
            if let taskerDetailsAndOfferAcceptViewController = segue.destination as? taskerDetailsAndOfferAcceptViewController {
                taskerDetailsAndOfferAcceptViewController.user = sender as? Users
                taskerDetailsAndOfferAcceptViewController.visitingUser = self.user
                taskerDetailsAndOfferAcceptViewController.task = task
                taskerDetailsAndOfferAcceptViewController.offeredUsers = offeredUsers
            }
        }
        
    }
    
}



// conforms to tableView protocol
extension myNewTaskViewController: UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            
            if offers.count == 0 {
                return 1
            } else {
                return offers.count
            }
        } else {
            if comments.count == 0 {
                return 1
            } else {
                return comments.count
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "offersCell", for: indexPath) as? offersCell  else {
                fatalError("error happended during dequeue")
            }
            if offers.count == 0 {
                //no offers made
                //cell.offeredUserDisplayName.text = "暂无竞标"
                cell.offeredUserProfileImg.isHidden = true
                cell.textLabel?.text = "暂无竞标"
                
            } else {
                //configure offersCell as offers have been made
                cell.delegate = self
                let offer = offers[indexPath.row]
              
                cell.textLabel?.text = nil
                cell.offeredUserProfileImg.isHidden = false
                
                Database.database().reference().child("Users").child(offer.offeredTakserID).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        let user = Users(dictionary:dictionary)
                        self.offeredUsers.append(user)
                        //rating star images
                        if user.aveRating == 5{
                            cell.offeredUserRatingImg.image = UIImage(named:"5 star rating")
                        } else if user.aveRating == 4 {
                            cell.offeredUserRatingImg.image = UIImage(named:"4 star rating")
                        } else if user.aveRating == 3 {
                            cell.offeredUserRatingImg.image = UIImage(named:"3 star rating")
                        } else if user.aveRating == 2 {
                            cell.offeredUserRatingImg.image = UIImage(named:"2 star rating")
                        } else if user.aveRating == 1 {
                            cell.offeredUserRatingImg.image = UIImage(named:"1 star rating")
                        } else {
                            cell.offeredUserRatingImg.image = UIImage(named:"0 star rating")
                        }
                        cell.user = user
                        cell.offeredUserDisplayName.text = user.displayName
                        cell.bidSuccessfulRate.text = "中标成功率:" + String(format: "%.2f", user.bidSuccessfulRate) + "%"
                        if user.profilePhotoUrl != "" {
                            let imgUrl = URL(string: (user.profilePhotoUrl))
                            cell.offeredUserProfileImg.kf.setImage(with: imgUrl)
                        } else {
                            cell.offeredUserProfileImg.image = UIImage(named:"profilePhoto")
                        }
                        
                    }
                })
                
                cell.offeredTime.text = timeAgoSinceDate(offer.offeredTime)
                
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as? commentsCell  else {
                fatalError("error happended during dequeue.")
            }
            
            if comments.count == 0 {
                //no comments made
                cell.commentedTaskerProfilImg.isHidden = true
                cell.commentReplyBtn.isHidden = true
                cell.commentLikeBtn.isHidden = true
                
                cell.expandBtn.isHidden = true
                cell.commentBody.text = nil
                cell.textLabel?.text = "暂无评论"
                
            } else {
                cell.delegate = self
                //configure commentsCell as comments have been made
                let comment = comments[indexPath.row]
                cell.textLabel?.text = nil
                cell.commentedTaskerProfilImg.isHidden = false
                cell.commentReplyBtn.isHidden = false
                //disable level 2 comment replies function
                if comment.isOP == false {
                    cell.commentReplyBtn.isHidden = true
                }
                cell.commentLikeBtn.isHidden = false
                cell.expandBtn.isHidden = false
                
                cell.userID = comment.commentedTaskerID
                cell.visitorID = Auth.auth().currentUser?.uid
                
                let indentWidth = 30.0
                cell.comment = comment
                
                cell.expandRepliesButtonLeadingConstraint.constant = CGFloat(comment.level * indentWidth)
                
                if let numberOfLikes = comment.numberOfLikes {
                    cell.commentLikeBtn.setTitle("\(numberOfLikes.count)赞", for: .normal)
                } else {
                    cell.commentLikeBtn.setTitle("0赞", for: .normal)
                }
                
//                if comment.isOP {
//                    cell.superview?.backgroundColor = .gray
//                }
                
                Database.database().reference().child("Users").child(comment.commentedTaskerID).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        
                        let user =  Users(dictionary:dictionary)
                        cell.user = user
                        cell.commentedTaskerDisplayName.text = user.displayName
                        
                        if user.profilePhotoUrl != "" {
                            let imgUrl = URL(string: user.profilePhotoUrl)
                            cell.commentedTaskerProfilImg.kf.setImage(with: imgUrl)
                        } else {
                            cell.commentedTaskerProfilImg.image = UIImage(named:"profilePhoto")
                        }
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                
                cell.commentedTaskerProfilImg.translatesAutoresizingMaskIntoConstraints = true
                cell.commentedTaskerProfilImg.layer.cornerRadius = 30
                cell.commentedTaskerProfilImg.layer.masksToBounds = true
                
                cell.commentBody.text = comment.content
                cell.commentedTime.text = timeAgoSinceDate(comment.createdTime)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            //let user = offeredUsers[indexPath.row]
//            //print(user.displayName)
//        } else {
//            print(indexPath.section,indexPath.row)
//        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "竞标"
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
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

//conforms to the UITextViewDelegate protocol

extension myNewTaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "我要评论"
            textView.textColor = UIColor.lightGray
        }
    }
}

//conforms to the MKMap protocol

extension myNewTaskViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        
        if let taskCoorodinate = task {
            let location = CLLocationCoordinate2DMake(taskCoorodinate.latitude, taskCoorodinate.longitude)
            mapV.centerCoordinate = location
            addAnnotations()
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier){
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else{
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.isEnabled = true
            annotationView.image = UIImage(named: "mapPin.png")
        }
        return annotationView
        
    }
    
    func addAnnotations(){
       guard let task = self.task else{
            return
        }
            let coordinate = CLLocationCoordinate2D(latitude: task.latitude, longitude: task.longitude)
            let annotation = customAnnotation(coordinate: coordinate)
            annotation.title = task.title
            annotation.subtitle = task.location
            mapV.addAnnotation(annotation)
        }
    

}




extension myNewTaskViewController:cellDelegate {
    

   func showCommentsReplies(parentComment:Comments, replies:[Comments]) {
        //1
    
        UIView.setAnimationsEnabled(true)
    
        //2
        tableView.beginUpdates()
    
    
        let parentCommentIndex = comments.index(of: parentComment)
    
        for (index, childComment) in replies.enumerated() {
            
            //3
            
            let childCommentIndex = parentCommentIndex! + (index + 1)
            comments.insert(childComment, at: childCommentIndex)
            let childCommentIndexPath = IndexPath(row: childCommentIndex, section: 1)
            
            tableView.insertRows(at: [childCommentIndexPath], with: .none)
        }
        //4
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    
    }
    
    func hideCommentsReplies(parentComment:Comments, replies:[Comments]) {
        UIView.setAnimationsEnabled(true)
        tableView.beginUpdates()
        
        //remove consecutively would damage the array order wont be correct unless delete at the same time oldRrr[1] != newArr[1]
        let parentCommentIndex = comments.index(of: parentComment)
        for ( _, _) in replies.enumerated() {
            
            let childCommentIndex = parentCommentIndex! + 1
            
            comments.remove(at: childCommentIndex)
            let childCommentIndexPath = IndexPath(row: childCommentIndex, section: 1)
            tableView.deleteRows(at: [childCommentIndexPath], with: .none)
            
            tableView.endUpdates()
            
        }
        
        //        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    
    func likeComment() -> (String) {
        //set the global value to prevent loadComments from happening
        self.shouldTableViewReload = false
        return task!.commentsID
    }
    
    func toggleLikeComment(comment:Comments,id:String) {
        for c in self.comments {
            if c.id == comment.id {
                
                if c.numberOfLikes == nil {
                    //no likes made yet,so append
                    c.numberOfLikes = [id]
                } else {
                    //likes made
                    if (c.numberOfLikes?.contains(id))! {
                        //like made by visitor,so remove
                        let index = c.numberOfLikes?.index(of: id)
                        c.numberOfLikes?.remove(at: index!)
                    } else {
                        //like nit made by visitor, so append
                        c.numberOfLikes?.append(id)
                    }
                }
                self.tableView.reloadData()
                let row = getCommentRow(comment:comment)
                self.tableView.scrollToBottomWhenCommentUpdated(row: row)
                break
            }
        }
    }
    
    func getCommentRow(comment:Comments) ->Int {
        
        return comments.index(of: comment)!
    }
    
    
    
    func segueToCommentReply(data: Comments) {
        self.performSegue(withIdentifier: "myTasktoCommentReply", sender: data)
    }
    
    
    func  commentsSegueToTaskerDetails(data:Users) {
        
        self.performSegue(withIdentifier: "myTaskCommentsToTaskerDetails", sender: data)
        
    }
    
//    func getCommenter(id:String,completionHandler:@escaping (Users) -> ()) {
//        Database.database().reference().child("Users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String:AnyObject] {
//                let commenter = Users(dictionary:dictionary)
//
//            }
//        })
//    }
    
//    func getCommenter(id:String) -> Users {
//
//        for user in commentedUsers {
//
//            if user.id == id {
//                return user
//            }
//        }
//
//        fatalError("cannot find the user in the comentedUsers[].")
//
//    }
    
    func offersSegueToTaskerDetails(data:Users) {
        
        self.performSegue(withIdentifier: "myTaskOffersToTaskerDetails", sender: data)
        
    }

    
}


