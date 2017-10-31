//
//  msgDetailsViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 17/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import MessageUI



class msgDetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate {
    
    //properties
    
    var barFrame:CGRect?
    
    var msgReceiver:Users?
    var msgSender:Users?
    
    var timeRef:Double?
    
    var messages:[Messages] = []
    
    var nameLable:UILabel?
    
    var msgField: UITextView?
    var tableView:UITableView?
    
    var footerView:UIView?
    
    func footerTypingViewSetup(){
        
        //
        let addImgButton:UIButton =  {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("+", for: .normal)
            button.setTitleColor(UIColor.blue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 26)
            button.addTarget(self, action: #selector(handleUploadTap), for: .touchUpInside)
            return button
        }()
        
        let sendButton:UIButton =  {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("发送", for: .normal)
            button.setTitleColor(UIColor.blue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.addTarget(self, action: #selector(msgSendBtnPressed), for:.touchUpInside)
            return button
        }()
        
        msgField = UITextView()
        
        msgField?.delegate = self
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        msgField?.layer.borderWidth = 0.5
        msgField?.layer.borderColor = borderColor.cgColor
        msgField?.layer.cornerRadius = 5.0
        msgField?.isScrollEnabled = false
        msgField?.text = "开始聊天"
        msgField?.textColor = UIColor.lightGray
        
        msgField?.translatesAutoresizingMaskIntoConstraints = false
        
        footerView?.addSubview(addImgButton)
        footerView?.addSubview(sendButton)
        footerView?.addSubview(msgField!)
        
        addImgButton.leftAnchor.constraint(equalTo: (footerView?.leftAnchor)!,constant:8).isActive = true
        addImgButton.bottomAnchor.constraint(equalTo: (footerView?.bottomAnchor)!,constant:-10).isActive = true
        
        addImgButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        addImgButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        msgField?.leftAnchor.constraint(equalTo: addImgButton.rightAnchor,constant:8).isActive = true
        msgField?.rightAnchor.constraint(equalTo: sendButton.leftAnchor,constant:-8).isActive = true
        msgField?.topAnchor.constraint(equalTo: (footerView?.topAnchor)!,constant:8).isActive = true
        msgField?.bottomAnchor.constraint(equalTo: (footerView?.bottomAnchor)!,constant:-8).isActive = true
        
        
        sendButton.bottomAnchor.constraint(equalTo: (footerView?.bottomAnchor)!,constant:-8).isActive = true
        sendButton.rightAnchor.constraint(equalTo: (footerView?.rightAnchor)!,constant:-8).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 31).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 31).isActive = true
        
        
    }
    
    
    @objc func handleUploadTap(){
        let optionMenu = UIAlertController(title: nil, message: "菜单", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "拍照", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        })
        let albumAction = UIAlertAction(title: "从手机相册选择", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                imagePicker.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        })
        
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(albumAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //handle video
            handleVideoSelectedForInfo(url: videoUrl)
            
        } else {
            //handle image
            handleImageSeletedForInfo(info: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForInfo(url:URL) {
        
        let filename = NSUUID().uuidString + ".mov"
        
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from:url, metadata: nil, completion: { (metadata, error) in
            
            if let error = error {
                print("Failed to upload of video",error)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString{
                
                if let thumnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                    
                    
    self.uploadToFireBaseStorageUsingImage(image: thumnailImage, completion: { (imageUrl) in
    
    
    let imageWidth = String(describing: thumnailImage.size.width)
    let imageHeight = String(describing: thumnailImage.size.height)
    let properties:[String:String] = ["content":"","imageUrl":imageUrl,"imageWidth":imageWidth,"imageHeight":imageHeight,"videoUrl":videoUrl]
    
    self.sendMessagesWithProperties(properties: properties)
    })
                    
                }
                
            }
            
        })
        
        uploadTask.observe(.progress) { (snapshot) in
//            self.nameLable?.text = String(describing: snapshot.progress!.completedUnitCount)
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount,  let totalUnitCount = snapshot.progress?.totalUnitCount {
                
                let uploadPercentage : Float64 = Float64(completedUnitCount) * 100 / Float64(totalUnitCount)
                
                if !uploadPercentage.isNaN {
                     self.nameLable?.text = String(format: "%.0f", uploadPercentage) + " %"
                }
               
            }
    
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.nameLable?.text = self.msgReceiver?.displayName
        }
        
    }
    
    private func thumbnailImageForFileUrl(fileUrl:URL) -> UIImage? {
        
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err{
            print(err)
        }
        return nil
    }
    
    
    private func handleImageSeletedForInfo(info:[String:Any]) {
        
        var selectedImageFromPicker:UIImage?
        
        if let editedimage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedimage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage  {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImg = selectedImageFromPicker {
            uploadToFireBaseStorageUsingImage(image: selectedImg, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image:selectedImg)
            })
        }
        
    }
    
    
    private func uploadToFireBaseStorageUsingImage(image:UIImage,completion:@escaping (_ imageUrl:String)->()){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child("\(imageName).jpg")
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if let error = error {
                    
                    print("an error occured:",error)
                }
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                if let downloadURL = metadata.downloadURL()?.absoluteString {
                    completion(downloadURL)
                    
//                    self.sendMessageWithImageUrl(imageUrl: downloadURL, image:image)
                }
            }
            
        }
        
        
    }
    
    private func sendMessageWithImageUrl(imageUrl:String,image:UIImage){
        
        let imageWidth = String(describing: image.size.width)
        let imageHeight = String(describing: image.size.height)
        
        let properties:[String:String] = ["content":"","imageUrl":imageUrl,"imageWidth":imageWidth,"imageHeight":imageHeight]
        
        sendMessagesWithProperties(properties: properties)
        
    }
    
    private func sendMessagesWithProperties(properties:[String:String]){
        
        
        let msgRef = Database.database().reference().child("Messages")
        let userRef = Database.database().reference().child("Users")
        
        if  msgSender?.messages[(msgReceiver?.id)!] != nil {
            
            let id = msgSender?.messages[(msgReceiver?.id)!]
            
            let msgID = msgRef.child(id!).childByAutoId().key
            let timeStamp = String(NSDate().timeIntervalSince1970)
            var messageToBeStore = [
                
                "sender": Auth.auth().currentUser?.uid,
                "receiver": msgReceiver?.id,
                "timeStamp":timeStamp,
                //                "content": msgField?.text!,
                "id":msgID,
                "belongedID":id
                
            ]
            
            properties.forEach({messageToBeStore[$0] = $1})
            
            msgRef.child(id!).child(msgID).setValue(messageToBeStore)
            
        } else {
            
            let id = msgRef.childByAutoId().key
            
            let msgID = msgRef.child(id).childByAutoId().key
            
            
            let timeStamp = String(NSDate().timeIntervalSince1970)
            
            var messageToBeStore = [
                
                "sender": Auth.auth().currentUser?.uid,
                "receiver": msgReceiver?.id,
                "timeStamp":timeStamp,
                //                "content": msgField?.text!,
                "id":msgID,
                "belongedID":id
                
            ]
            
            properties.forEach({messageToBeStore[$0] = $1})
            
            msgRef.child(id).child(msgID).setValue(messageToBeStore)
            userRef.child((Auth.auth().currentUser?.uid)!).child("messages").child((msgReceiver?.id)!).setValue(id)
            
            userRef.child((msgReceiver?.id)!).child("messages").child((Auth.auth().currentUser?.uid)!).setValue(id)
            
            msgReceiver?.messages[(msgSender?.id)!] = id
            msgSender?.messages[(msgReceiver?.id)!] = id
            
            loadMessages(msgID: id)
            
        }
        
        msgField?.text = ""
        

    }
    
    @objc func msgSendBtnPressed(_ sender: Any) {
        
        if msgField?.text != "" && msgField?.text != "开始聊天" {
            let properties:[String:String] = ["content":(msgField?.text)!]
            sendMessagesWithProperties(properties: properties)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden=true
        //        if  let tabBar=self.tabBarController?.tabBar {
        //            self.barFrame=tabBar.frame
        //
        //            UIView.animate(withDuration: 0.3, animations: { () -> Void in
        //                let newBarFrame=CGRect(x:self.barFrame!.origin.x, y:self.view.frame.size.height, width:self.barFrame!.size.width, height: self.barFrame!.size.height)
        //                tabBar.frame=newBarFrame
        //            }, completion: { (Bool) -> Void in
        //                tabBar.isHidden=true
        //            })
        //
        //        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden=false;
        //        if self.barFrame != nil {
        //            UIView.animate(withDuration: 0.3, animations: { () -> Void in
        //                let newBarFrame=CGRect(x:self.barFrame!.origin.x, y:self.view.frame.size.height-self.barFrame!.size.height, width:self.view.frame.size.width,height: self.barFrame!.size.height)
        //                self.tabBarController?.tabBar.frame=newBarFrame
        //            })
        //
        //        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerViewConfigure()
        tableViewConfigure()
        footerTypingViewSetup()
        keyboardConfigure()
        checkIfMsgExisted()
        
    }
    
    func headerViewConfigure() {
        //titleView Configure
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleToFill
        if msgReceiver?.profilePhotoUrl != "" {
            let imgUrl = URL(string:(msgReceiver?.profilePhotoUrl)!)
            profileImageView.kf.setImage(with: imgUrl)
        } else {
            profileImageView.image = UIImage(named:"profilePhoto")
        }
        
        containerView.addSubview(profileImageView)
        
        //constraints
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLable = UILabel()
        
        containerView.addSubview(nameLable!)
        nameLable?.text = msgReceiver?.displayName
        nameLable?.translatesAutoresizingMaskIntoConstraints = false
        //x,y,width,height
        nameLable?.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant:8).isActive = true
        nameLable?.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLable?.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLable?.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        let block = UIBarButtonItem(title: "举报", style: .plain, target: self, action: #selector(report))
        
        navigationItem.rightBarButtonItems = [block]
        
    }
    
    
    func tableViewConfigure(){
        
        
        footerView = UIView()
        footerView?.backgroundColor = UIColor.groupTableViewBackground
        
        self.view.addSubview(footerView!)
        
        
        
        tableView = UITableView()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
        self.view.addSubview(tableView!)
        tableView?.register(customMessageCell.self, forCellReuseIdentifier: "messageCell")
        
        tableView?.separatorStyle = .none
        tableView?.allowsSelection = false
        
        
        tableView?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView?.bottomAnchor.constraint(equalTo: (self.footerView?.topAnchor)!).isActive = true
        tableView?.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        
        footerView?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        footerView?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        footerView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        //        footerView?.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        footerView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 130
        
    }
    
    func keyboardConfigure(){
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    
    
    //MARK: loading
    
    func checkIfMsgExisted() {
        
        for (key,val) in (msgSender?.messages)!{
            
            if key == msgReceiver?.id {
                let msgID = val
                loadMessages(msgID: msgID)
                break
            }
            
        }
        
    }
    
    
    func loadMessages(msgID:String){
        
        
        let msgRef =  Database.database().reference().child("Messages").child(msgID)
        
        msgRef.observe(DataEventType.value, with: {(snapshot) in
            
            self.messages.removeAll()
            
            for msg in snapshot.children.allObjects as![DataSnapshot] {
                
                guard let dictionary = msg.value as? [String:String] else {
                    return
                }
              
                let message = Messages(dictionary: dictionary)
                self.messages.append(message)
                
            }
            
            self.tableView?.reloadData()
            self.tableView?.scrollToBottomWithOneSection()
        })
        
    }
  
    //setup cell
    
    func setupCell(cell:customMessageCell,message:Messages) {
            
        if message.receiver == msgReceiver?.id {
            // sender is self
            cell.bubble.backgroundColor = UIColor(rgb:0x94D8FF)
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
            
            if msgSender?.profilePhotoUrl != ""
            {
                let imgUrl = URL(string:(msgSender?.profilePhotoUrl)!)
                cell.msgSenderProfileImg.kf.setImage(with: imgUrl)
                cell.msgReciverProfileImg.image = nil
                
            } else {
                cell.msgSenderProfileImg.image = UIImage(named:"profilePhoto")
                cell.msgReciverProfileImg.image = nil
            }
            
        } else {
            //sender is other
            
            cell.bubble.backgroundColor = UIColor.white
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
            
            if msgReceiver?.profilePhotoUrl != "" {
                let imgUrl = URL(string:(msgReceiver?.profilePhotoUrl)!)
                cell.msgReciverProfileImg.kf.setImage(with: imgUrl)
                cell.msgSenderProfileImg.image = nil
            } else {
                cell.msgReciverProfileImg.image = UIImage(named:"profilePhoto")
                cell.msgSenderProfileImg.image = nil
            }
            
        }
        
        //message image
        
        if message.imageUrl != "" && message.content == "" {
            
            let imgUrl = URL(string:message.imageUrl)
            cell.messageImageView.kf.setImage(with: imgUrl)
            cell.messageImageView.isHidden = false
            cell.bubble.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
            cell.messageImageView.image = nil
        }
        
        //message time
        
        if NSDate().timeIntervalSince1970 - 86400 > message.timeStamp.doubleValue {
            
            let timeStampDate = Date(timeIntervalSince1970:message.timeStamp.doubleValue)
            cell.timeLabel.text = timeAgoSinceDate(timeStampDate)
            
            if let timeRef = timeRef{
                //only display timeLabel when two consecutive messages are lapsed more than 60 seconds
                if message.timeStamp.doubleValue - timeRef < 60 && timeRef != message.timeStamp.doubleValue {
                    cell.timeLabel.text = ""
                }
            }
            
            timeRef = message.timeStamp.doubleValue
            
            
        } else {
            
            let timeStampDate = Date(timeIntervalSince1970:message.timeStamp.doubleValue)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            cell.timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
            
            if let timeRef = timeRef{
                //only display timeLabel when two consecutive messages are lapsed more than 60 seconds
                if message.timeStamp.doubleValue - timeRef < 60 && timeRef != message.timeStamp.doubleValue {
                    cell.timeLabel.text = ""
                }
            }
            
            timeRef = message.timeStamp.doubleValue
        }
        
    }
    
    //delegate func
    
    var startingFrame:CGRect?
    var blackBackGroundView:UIView?
    var startingImageView:UIView?
    
    func performZoomInForStartingImageView(startingImageView:UIImageView){
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        //        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackGroundView = UIView(frame: keyWindow.frame)
            blackBackGroundView?.backgroundColor = UIColor.black
            keyWindow.addSubview(blackBackGroundView!)
            
            blackBackGroundView?.alpha = 0
            // blackBackGroundView id added first thust having higher z-index
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackGroundView?.alpha = 1
                self.footerView?.alpha = 0
                
                let height = self.startingFrame!.height/self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: { (completed) in
                //nothing
                
            })
            
        }
        
    }
    
    @objc func handleZoomOut(tapGesture:UITapGestureRecognizer){
        if let zoomOutView = tapGesture.view {
            
            //animate back to the controller
            //            zoomOutView.layer.cornerRadius = 16
            //            zoomOutView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutView.frame = self.startingFrame!
                self.blackBackGroundView?.alpha = 0
                self.footerView?.alpha = 1
            }, completion: { (completed) in
                //some other logic
                zoomOutView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
        }
    }
    
}


extension msgDetailsViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            return 1
        } else {
            return messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! customMessageCell
        
        cell.msgDetailsViewController = self
        
        if messages.count == 0 {
            cell.playButton.isHidden = true
            let text = "你和\(String(describing: (msgReceiver?.displayName)!))还没有任何聊天记录，现在开始聊天吧！"
            cell.bubbleHeightAnchor?.constant = estimateFrameForText(text: text).height + 45
            cell.msgBody.text = text

        } else {
            
            let message = messages[indexPath.row]
            
            cell.message = message
            
            //this check is for imageURL without text
            if message.content != ""{
                //this is a text
                cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.content).width + 21 //was 25
                cell.bubbleHeightAnchor?.constant = estimateFrameForText(text: message.content).height + 21
                cell.msgBody.isHidden = false
            } else {
                //image does exist
                
                let width = Float(message.imageWidth)
                let height = Float(message.imageHeight)
                
                cell.bubbleWidthAnchor?.constant = 200
                cell.bubbleHeightAnchor?.constant = CGFloat(height!/width! * 200.0)
                cell.msgBody.isHidden = true
            }
            
            cell.playButton.isHidden = message.videoUrl == ""
       
            //
            
            setupCell(cell:cell,message: message)
            cell.msgBody.text = message.content
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if messages.count > 0 {
            let message = messages[indexPath.row]
            
            if message.content != ""{
                //text only
                return estimateFrameForText(text: message.content).height + 66
            } else  {
                //image does exist
                let width = Float(message.imageWidth)
                let height = Float(message.imageHeight)
                
                return CGFloat(46 + height!/width! * 200.0)
            }
            
        } else {
            
            //messages have not been loaded yet
            return 0
            
        }
        
    }
    
    @objc private func report(){
        if !MFMailComposeViewController.canSendMail() {
            self.showAlert(withTitle: "粗错了", message: "你目前使用的设备不支持该功能")
            return
        }
        
        guard let name = self.self.msgSender?.displayName,let nameToBeReported = self.msgReceiver?.displayName else{
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["taskmateau@gmail.com"])
        composeVC.setSubject("举报:\(nameToBeReported)")
        composeVC.setMessageBody("举报人:\(name),被举报人:\(nameToBeReported)", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    //mail delegate
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            print(error)
        }
        //send alert if user tap "send" button
        if (result.rawValue == 2){
            showAlert(withTitle: "提示", message: "您对该条任务的举报已提交，澳洲百事通管理团队将会尽快审核您的举报，如举报内容属实，团队会在24小时内采取相应措施")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension msgDetailsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "开始聊天"
            textView.textColor = UIColor.lightGray
        }
    }
}


