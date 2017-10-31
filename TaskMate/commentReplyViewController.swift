//
//  commentReplyViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 11/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase


class commentReplyViewController: UIViewController {
    
    var comment:Comments?
    var comments:[Comments] = []
    var id:String?
    var user:Users?
    
    
    //IBOutlet properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentField: UITextView!
    
    //IBOutlet actions
    
    @IBAction func replyToCommentBtn(_ sender: Any) {
        
        
        if commentField.text != "" && commentField.text != "我要评论" {
            
            let commentRef = Database.database().reference().child("Comments")
            
            let CommentID = comment!.id
            let id = self.id!
            let key = commentRef.child(id).child(CommentID).child("replies").childByAutoId().key
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
            let createdTime = formatter.string(from: Date())
            
            let commentToBeStored = [
                "id":key,
                "content": commentField.text!,
                "createdTime": createdTime,
                "belongedTask":self.comment?.belongedTask.id,
                "commentedTaskerName":self.user?.displayName,
                "commentedTaskerProfileUrl":self.user?.profilePhotoUrl,
                "commentedTaskerID":Auth.auth().currentUser?.uid,
                "parentComment":comment?.id
            ]
            
            commentRef.child(id).child(CommentID).child("replies").child(key).setValue(commentToBeStored)
            
            let newTask = Tasks(title: "title",desc: "desc")
            let newComment = Comments(commentField.text!,newTask,Date(),key,(self.user?.displayName)!,(self.user?.profilePhotoUrl)!,(Auth.auth().currentUser?.uid)!)
            newComment.level = 1
            newComment.isOP = false
            
            comments.append(newComment)
            
            tableView.reloadData()
            
            commentField.text = "我要评论"
            commentField.textColor = UIColor.lightGray
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentFieldConfigure()
        tableViewConfigure()
        keyboardConfigure()
        getComments()
        
        
    }
    
        
    // get comments
    
    func getComments(){
        
        comments.append(comment!)
        
        if comment?.replies.count != 0 {
            for replies in (comment?.replies)! {
                comments.append(replies)
            }
        }
        
    }
    
    // configuration
    
    func tableViewConfigure(){
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        
//        tableView.scrollToBottom()
    }
    
    func commentFieldConfigure(){
        
        commentField.delegate = self
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        commentField.layer.borderWidth = 0.5
        commentField.layer.borderColor = borderColor.cgColor
        commentField.layer.cornerRadius = 5.0
        commentField.text = "我要评论"
        commentField.textColor = UIColor.lightGray
        
    }
    
    func keyboardConfigure(){
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    
    
}

extension commentReplyViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! commentToReplyCell
        
        cell.delegate = self
        
        let comment = comments[indexPath.row]
        
        cell.comment = comment
        cell.visitorID = self.user?.id
        
        
        if !comment.isOP {
            cell.expandRepliesButtonLeadingConstraint.constant = 20
            cell.commentLikeBtn.isHidden = true
        }
        
        if let numberOfLikes = comment.numberOfLikes {
            cell.commentLikeBtn.setTitle("\(numberOfLikes.count)赞", for: .normal)
        } else {
            cell.commentLikeBtn.setTitle("0赞", for: .normal)
        }
        
        cell.commentedTaskerDisplayName.text = comment.commentedTaskerName
        
        if comment.commentedTaskerProfileUrl != "" {
            let imgUrl = URL(string: (comment.commentedTaskerProfileUrl))
            cell.commentedTaskerProfilImg.kf.setImage(with: imgUrl)
        }
        cell.commentedTaskerProfilImg.translatesAutoresizingMaskIntoConstraints = true
        cell.commentedTaskerProfilImg.layer.cornerRadius = 30
        cell.commentedTaskerProfilImg.layer.masksToBounds = true
        
        cell.commentBody.text = comment.content
        cell.commentedTime.text = timeAgoSinceDate(comment.createdTime)
        
        
        
        return cell
    }
    
    //delete the extra footer view
    func tableView
        (_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    
}

extension commentReplyViewController: UITextViewDelegate {
    
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


//protocol for like commons

protocol CommentReplyCellDelegate:class {
    
    func likeComment() ->(String)
    func reloadTblView(comment:Comments,id:String)
    
}

extension commentReplyViewController:CommentReplyCellDelegate {
    
    func likeComment() -> (String) {
        return id!
    }
    
    func reloadTblView(comment:Comments,id:String) {
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
                break
            }
        }
    
    }
    
}
