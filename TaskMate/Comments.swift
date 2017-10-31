//
//  Comments.swift
//  TaskMate
//
//  Created by Wei Zheng on 29/6/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Comments:NSObject {
    
    var content:String
   // var poster: Users = ""
    var createdTime:Date = Date()
    var numberOfLikes:[String]?
    var belongedTask:Tasks = Tasks(title: "test",desc: "test")
    var id:String = ""
    var commentedTaskerName:String = ""
    var commentedTaskerProfileUrl:String = ""
    var commentedTaskerID:String = ""
    var replies:[Comments] = []
    var level:Double = 0.0
    var isExpanded:Bool = false
    var isOP:Bool = true
    var parentComment:String = ""  //for setting number of likes
  
    init(_ content:String) {
        self.content = content
    }
    
    init(_ content:String,_ belongedTasks:Tasks) {
        self.content = content
        self.belongedTask = belongedTasks
    }
    
    //for comments
    
    init(dictionary:[String:AnyObject],task:Tasks) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
        
        self.id = dictionary["id"] as! String
        self.content = dictionary["content"] as! String
        self.createdTime = dateFormatter.date(from: dictionary["createdTime"] as! String)!
        if let numberOfLikesArr = dictionary["numberOfLikes"] {
            self.numberOfLikes = numberOfLikesArr as? [String]
        }
//        self.numberOfLikes = Int(dictionary["numberOfLikes"] as! String)!
        self.commentedTaskerName = dictionary["commentedTaskerName"] as! String
        self.commentedTaskerProfileUrl = dictionary["commentedTaskerProfileUrl"] as! String
        self.commentedTaskerID = dictionary["commentedTaskerID"] as! String
        self.belongedTask = task
        
    }
    //for comments replies
    init(dic:[String:AnyObject],task:Tasks) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
        
        self.id = dic["id"] as! String
        self.content = dic["content"] as! String
          self.createdTime = dateFormatter.date(from: dic["createdTime"] as! String)!
        if let numberOfLikesArr = dic["numberOfLikes"] {
            self.numberOfLikes = numberOfLikesArr as? [String]
        }
        self.commentedTaskerName = dic["commentedTaskerName"] as! String
        self.commentedTaskerProfileUrl = dic["commentedTaskerProfileUrl"] as! String
        self.commentedTaskerID = dic["commentedTaskerID"] as! String
        self.belongedTask = task
        
        let parentComment = dic["parentComment"]
        self.isOP = false
        self.parentComment = parentComment! as! String
        self.level = 1

    }
    
    //for commentReply
    init(_ content:String,_ belongedTasks:Tasks,_ createdTime:Date,_ id:String,_ commentedTaskerName:String,_ commentedTaskerProfileUrl:String,_ commentedTaskerID:String) {
        self.content = content
        self.belongedTask = belongedTasks
        self.createdTime = createdTime
        self.id = id
        self.commentedTaskerName = commentedTaskerName
        self.commentedTaskerProfileUrl = commentedTaskerProfileUrl
        self.commentedTaskerID = commentedTaskerID
    }
    
 
    
}
