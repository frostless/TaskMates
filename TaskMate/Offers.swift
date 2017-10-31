//
//  OfferedTaskers.swift
//  TaskMate
//
//  Created by Wei Zheng on 7/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import Foundation
import UIKit
import os.log


class Offers:NSObject {
    
    var offeredTaskerName:String = ""
    var offeredTime:Date = Date()
    var offeredTakserID:String = ""
    var offeredTaskerPhotoImgUrl:String = ""
//    var bidSuccessfulRate:Double = 0.0
//    var commentRating:Double = 0.0
    
    
    init(dictionary:[String:String]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
        
        self.offeredTaskerName = dictionary["offeredTaskerName"]!
        self.offeredTime = dateFormatter.date(from: dictionary["createdTime"]!)!
        self.offeredTakserID = dictionary["offeredTaskerID"]!
        self.offeredTaskerPhotoImgUrl = dictionary["offerTaskerProfileUrl"]!
//        self.bidSuccessfulRate = Double(dictionary["bidSuccessfulRate"]!)!
//        self.commentRating = Double(dictionary["commentRating"]!)!
 
    }
}

