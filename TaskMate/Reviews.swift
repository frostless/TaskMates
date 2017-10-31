//
//  File.swift
//  TaskMate
//
//  Created by Wei Zheng on 2/9/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import os.log

class Reviews:NSObject {
    var toID:String?
    var fromID:String?
    var content:String?
    var id:String?
    var taskID:String?
    var createdTime:Date?
    
    init(dictionary:[String:AnyObject]) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
        
        self.toID = dictionary["toID"] as? String
        self.fromID = dictionary["fromID"] as? String
        self.content = dictionary["content"] as? String
        self.taskID = dictionary["taskID"] as? String
        self.id = dictionary["id"] as? String
        self.createdTime = formatter.date(from:dictionary["createdTime"] as!String)
        
    }
    
    
    init(_ toID:String,_ fromID:String, _ content:String, _ id:String, _ taskID:String,_ createdTime:Date) {
        self.toID = toID
        self.fromID = fromID
        self.content = content
        self.taskID = taskID
        self.id = id
        self.createdTime = createdTime
      
    }
    
    
}
