//  Tasks.swift
//  TaskMate
//
//  Created by Zheng Wei on 5/20/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import os.log
import CoreLocation
class Tasks: NSObject{
    

    var title: String
    var id: String = ""
    // var attachment: UIImage?
    var desc: String
    var dueDate: Date = Date()
    var createdDate: Date = Date()
    var latitude: Double = -33.872749599999999
    var longitude: Double = 151.2061827
    var location: String = "悉尼"
    var budget: Int = 0
    var hourlyRate: Int = 0
    var hours: Int = 0
    var taskerNumber: Int = 0
    var isOnline: Bool = false
    var ishourlyRate: Bool = false
    var postedUser:String = ""
    var user:Users = Users()
//    var comments: [Comments] = [] //= Array<Comments>()
    var imageURL:String = "" //tasker's image
    var commentsID:String = ""// reference to fetch comments in comments node
    var assignedTasker: String = ""
    var offeredUsers:[String] = []
    
    var clLocation: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.clLocation)
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tasks")
    
    
    //MARK: Initialization
    
    init(title: String,desc: String) {
        
        
        self.title = title
        //self.attachment = attachment
        self.desc = desc
        
    }
    
//    
//    init(title: String,desc: String,dueDate:Date,latitude: Double,longitude: Double,location: String,budget:Int,hourlyRate:Int,hours: Int,taskerNumber:Int,isOnline:Bool,ishourlyRate:Bool,createdDate:Date,comments:[Comments]) {
//        
//        
//        
//        self.title = title
//        //self.attachment = attachment
//        self.desc = desc
//        self.dueDate = dueDate
//        self.budget = budget
//        self.hourlyRate = hourlyRate
//        self.hours = hours
//        self.taskerNumber = taskerNumber
//        self.isOnline =  false
//        self.ishourlyRate = false
//        self.latitude = latitude
//        self.longitude = longitude
//        self.location = location
//        self.createdDate = createdDate
//        self.comments = comments
//    }
    
    init(dictionary:[String:AnyObject]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
        
        self.title = dictionary["title"] as! String
        self.id = dictionary["id"] as! String
        self.desc = dictionary["desc"] as! String
        self.dueDate = dateFormatter.date(from: dictionary["dueDate"] as! String)!
        self.budget = Int(dictionary["budget"] as! String)!
        self.hourlyRate = Int(dictionary["hourlyRate"] as! String)!
        self.hours = Int(dictionary["hours"] as! String)!
        self.taskerNumber = Int(dictionary["taskerNumber"] as! String)!
        self.isOnline = Bool(dictionary["isOnline"] as! String)!
        self.ishourlyRate = Bool(dictionary["ishourlyRate"] as! String)!
        self.latitude = Double(dictionary["latitude"] as!String)!
        self.longitude = Double(dictionary["longitude"] as!String)!
        self.location = dictionary["location"] as! String
        self.createdDate = dateFormatter.date(from: dictionary["createdDate"] as! String)!
        self.imageURL = dictionary["imageURL"] as! String
        self.postedUser = dictionary["postedUser"] as! String
        
        if let assignedTaskerString = dictionary["assignedTasker"] {
            self.assignedTasker = assignedTaskerString as! String
        }
        
        if let commentsIDString = dictionary["commentsID"] {
            self.commentsID = commentsIDString as! String
        } else {
            self.commentsID = "nil" //refer to loadlComments
        }
        
        if let offeredUsersDic = dictionary["offeredUsers"] {
            let offeredUsersArray = offeredUsersDic as! Dictionary<String, AnyObject> as Dictionary
            for (key, _) in offeredUsersArray {
                self.offeredUsers.append(key)
            }
        }
        
    }

   }
