//
//  Users.swift
//  TaskMate
//
//  Created by Wei Zheng on 29/6/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Users:NSObject  {
    var id:String = ""
    var displayName:String = ""
    //var tasks:[Tasks] = []
    var sinceTime:Date = Date()
    var email:String = ""
    var passWord:String = ""
    var profilePhotoUrl:String = ""
    var reviews:[String:String] = [:]
    var skills:[String] = []
    var languages:[String] = []
    var selfDescription: String = ""
    //var postedTasks:[Tasks] = []
    //var offeredTasks:[Tasks] = []
    var postedTasks:[String] = []
    var offeredTasks:[String] = []
    var acceptedTasks:[String] = []
    //    var finishedTasks:[Tasks] = []
    //    var unFinishedTasks:[Tasks] = []
    var messages:[String:String] = [:] //for messages
    var rating:[String:Int] = [:]
    var ratingUsers:[String:String] = [:]//record who made the rating
    var blockedUsers:[String]?
    
    var bidSuccessfulRate: Double {
        //divisor cannot be 0
        if acceptedTasks.count == 0{
            return 0.0
        } else {
            return Double(acceptedTasks.count)/Double(offeredTasks.count)*100
        }
    }
    
    var aveRating: Double {
        
        let  r0 = rating["0"] == nil ? 0 : rating["0"]
        let  r1 = rating["1"] == nil ? 0 : rating["1"]
        let  r2 = rating["2"] == nil ? 0 : rating["2"]
        let  r3 = rating["3"] == nil ? 0 : rating["3"]
        let  r4 = rating["4"] == nil ? 0 : rating["4"]
        let  r5 = rating["5"] == nil ? 0 : rating["5"]
        
        let divisor = Double(r0!+r1!+r2!+r3!+r4!+r5!)
        let divident = Double(r0!+r1!+r2!*2+r3!*3+r4!*4+r5!*5)
        if divisor == 0 {
            return 0.0
        }
        let result = divident/divisor
        return result.rounded()
    }
    
    
    init(id:String,displayName:String,sinceTime:Date,email:String) {
        self.id = id
        self.displayName = displayName
        self.sinceTime = sinceTime
        self.email = email
    }
    
    init(id:String,displayName:String,sinceTime:Date,email:String,profilePhotoUrl:String) {
        self.id = id
        self.displayName = displayName
        self.sinceTime = sinceTime
        self.email = email
        self.profilePhotoUrl = profilePhotoUrl
    }
    
    
    init(dictionary:[String:AnyObject]){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
        
        self.id = dictionary["id"] as! String
        self.displayName = dictionary["displayName"] as! String
        let sinceTime = dictionary["sinceTime"] as! String
        self.sinceTime = formatter.date(from: sinceTime)!
        self.email = dictionary["email"] as! String
        
        if let profilePhotoUrl = dictionary["profilePhotoUrl"] as? String {
            self.profilePhotoUrl = profilePhotoUrl
        }
        
        if let selfDescription = dictionary["description"] as? String {
            self.selfDescription = selfDescription
        }
        
        
        if let dicOfferedTasks = dictionary["offeredTasks"]{
            let offeredTasks = dicOfferedTasks as! Dictionary<String, Bool> as Dictionary
            for (key, _) in offeredTasks {
                self.offeredTasks.append(key)
            }
        }
        
        if let dicPostedTasks = dictionary["postedTasks"]{
            let postedTasks = dicPostedTasks as! Dictionary<String, Bool> as Dictionary
            for (key, _) in postedTasks {
                self.postedTasks.append(key)
            }
        }
        
        if let dicAcceptedTasks = dictionary["acceptedTasks"]{
            let acceptedTasks = dicAcceptedTasks as! Dictionary<String, Bool> as Dictionary
            for (key, _) in acceptedTasks {
                self.acceptedTasks.append(key)
            }
        }
        
        if let dicMessages = dictionary["messages"]{
            let msg = dicMessages as! Dictionary<String, String> as Dictionary
            for (key,val) in msg {
                self.messages[key] = val
            }
        }
        
        if let dicReviews = dictionary["reviews"]{
            let reviews = dicReviews as! Dictionary<String, String> as Dictionary
            for (key,val) in reviews {
                self.reviews[key] = val
            }
        }
        
        if let skillsArr = dictionary["skills"]{
            for skill in skillsArr as! NSArray{
                self.skills.append(skill as! String)
            }
        }
        
        if let languagesArr = dictionary["languages"]{
            for language in languagesArr as! NSArray{
                self.languages.append(language as! String)
            }
        }
        
        if let dicRating = dictionary["rating"]{
            let rating = dicRating as! Dictionary<String, Int> as Dictionary
            for (key,val) in rating {
                self.rating[key] = val
            }
        }
        
        if let dicRatingUsers = dictionary["ratingUsers"]{
            let ratingUsers = dicRatingUsers as! Dictionary<String, String> as Dictionary
            for (key,val) in ratingUsers {
                self.ratingUsers[key] = val
            }
        }
        
        if let blockedUsers = dictionary["blockedUsers"] {
            var array:[String] = []
            for user in blockedUsers as! NSArray{
                array.append(user as! String)
                self.blockedUsers = array
            }
        }
        
    }
    
    override init(){
        
    }
    
    func isTasksPoster()-> Bool{
        
        return postedTasks.count == 0 ? true : false
    }
    
    func isTasksSolver()-> Bool{
        
        return acceptedTasks.count == 0 ? true : false
    }
    
    
}

