//
//  File.swift
//  TaskMate
//
//  Created by Wei Zheng on 17/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//


import UIKit
import Firebase

class Messages: NSObject {
    
    var sender: String = ""
    var receiver:String = ""
    var timeStamp:NSNumber = 0
    var content:String = ""
    var id:String = ""
    var belongedID:String = ""
    var imageUrl:String = ""
    var imageHeight:String = ""
    var imageWidth:String = ""
    var videoUrl:String = ""

    
    init(dictionary:[String:String]){
        self.sender = dictionary["sender"]!
        self.receiver = dictionary["receiver"]!
        self.timeStamp = NSNumber(value: Double((dictionary["timeStamp"])!)!)
        self.content = dictionary["content"]!
        self.id = dictionary["id"]!
        self.belongedID = dictionary["belongedID"]!
        
        if let imageUrl = dictionary["imageUrl"],let imageWidth = dictionary["imageWidth"], let imageHeight = dictionary["imageHeight"]  {
            self.imageUrl = imageUrl
            self.imageWidth = imageWidth
            self.imageHeight = imageHeight
        }
        
        if let videoUrl = dictionary["videoUrl"]{
            self.videoUrl = videoUrl
        }
        
    }
    
    func chatPartnerId() -> String {
         return receiver == Auth.auth().currentUser?.uid ? sender : receiver
    }
    
}
