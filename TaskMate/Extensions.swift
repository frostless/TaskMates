//
//  Extensions.swift
//  TaskMate
//
//  Created by Wei Zheng on 23/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SystemConfiguration

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func loadImageUsingCacheWithUrlString(urlString:URL) {
        
        let url = String(describing: urlString)
        
        //check cache for image first
        
        if let cachedImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: urlString, completionHandler: { (data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data:data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: url as AnyObject )
                    
                    self.image = downloadedImage
                    
                    
                }
                
                
            }
            
        }).resume()
        
    }
 
}


extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}



extension UIViewController {
    
    //time calculation
    func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!)年前"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1年前"
            } else {
                return "去年"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!)月前"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1个月前"
            } else {
                return "上个月"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)周前"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1周前"
            } else {
                return "上周"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!)天前"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1天前"
            } else {
                return "昨天"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!)小时前"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1小时前"
            } else {
                return "1小时以内"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!)分钟前"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1分钟前"
            } else {
                return "1分钟内"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!)秒前"
        } else {
            return "就在刚刚"
        }
    }
    
    //bubble calculation
    
    func estimateFrameForText(text:String) -> CGRect {
        let size = CGSize(width: self.view.frame.width - 144, height: 1000) // width was 230 before
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18)], context: nil)
    }
    
    func estimateFrameForBubble(text:String) -> CGRect {
        let size = CGSize(width: self.view.frame.width - 32, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18)], context: nil)
    }
    
    func estimateFrameForReviewBubble(text:String) -> CGRect {
        let size = CGSize(width: self.view.frame.width - 88, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18)], context: nil)
    }
    
    // setup review cell for myViews and allViews
    
    func setupNameAndImageProfile(review:Reviews,cell:reviewsToTaskerCell) {
        guard let fromID = review.fromID else {
            return
        }
        let reviewRef = Database.database().reference().child("Users").child(fromID)
        reviewRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                return
            }
            cell.nameLabel.text = dictionary["displayName"] as? String
            if let profilePhotoUrl = dictionary["profilePhotoUrl"]{
                let imgUrl = URL(string: profilePhotoUrl as! String)
                cell.profileImageView.kf.setImage(with: imgUrl)
            } else {
                cell.profileImageView.image = UIImage(named:"profilePhoto")
            }
        })
        
    }
    
    //show alert
    func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    //color
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        
        return swearWords
            .reduce(false) { $0 || text.contains($1.lowercased()) }
    }
    
    
    func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "加载中..."
    }
    
    func hideLoadingHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

}


extension UINavigationController {
    
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
}

extension UITableViewCell {
    //time calculation
    func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!)年前"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1年前"
            } else {
                return "去年"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!)月前"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1个月前"
            } else {
                return "上个月"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)周前"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1周前"
            } else {
                return "上周"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!)天前"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1天前"
            } else {
                return "昨天"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!)小时前"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1小时前"
            } else {
                return "1小时以内"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!)分钟前"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1分钟前"
            } else {
                return "1分钟内"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!)秒前"
        } else {
            return "就在刚刚"
        }
        
    }

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}



