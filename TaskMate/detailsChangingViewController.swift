//  detailsChangingViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 20/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher

class detailsChangingViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    //IBOUTlests
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var user:Users?
    var textField:UITextField?
    var editingView:UIView?
    var seperaterView:UIView?
    var changeButton:UIButton?
    var textView:UITextView?
    
    @IBAction func backToProfileSetting(_ sender: Any) {
        
        performSegue(withIdentifier: "backToProfile", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewConfigure()
        UIonfigure()
        keyboardConfigure()
        profileImgChange()
        nameChange()
    }
    
    //UI
    
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
    
    
    
    func tableViewConfigure(){
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    func UIonfigure(){
        
        if user?.profilePhotoUrl != "" {
            
            let imgUrl = URL(string: (user?.profilePhotoUrl)!)
            profileImg.kf.setImage(with: imgUrl)
        } else {
            profileImg.image = UIImage(named:"profilePhoto")
            
        }
        
        profileImg.translatesAutoresizingMaskIntoConstraints = true
        profileImg.layer.cornerRadius = 15
        profileImg.layer.masksToBounds = true
        
        profileImg.isUserInteractionEnabled = true
        
        nameLabel.text = user?.displayName
        
    }
    
    func keyboardConfigure(){
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    //    func removeFooterView(){
    //
    //        let tap = UITapGestureRecognizer(target: self.view, action: #selector(deleteFooterView))
    //        tap.cancelsTouchesInView = false
    //        self.view.addGestureRecognizer(tap)
    //
    //    }
    
    // imagePicker Configure
    
    func profileImgChange(){
        profileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImgPressed)))
        
    }
    
    @objc func profileImgPressed(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        })
        
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(albumAction)
        optionMenu.addAction(cancelAction)
        
        
        //for ipad
        if let popoverPresentationController = optionMenu.popoverPresentationController {
            let height = profileImg.bounds.height + UIApplication.shared.statusBarFrame.height
            let width = profileImg.bounds.width
            guard let superview = profileImg.superview else {
                return
            }
            let locationY = profileImg.frame.origin.y + height + superview.frame.origin.y
            let locationX = profileImg.frame.origin.x
                + width/2
            
            popoverPresentationController.sourceView = self.view
            optionMenu.popoverPresentationController?.sourceRect = CGRect(x: locationX, y: locationY, width: 1.0, height: 1.0)
            self.present(optionMenu, animated: true, completion: nil)
            return
            
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker:UIImage?
        
        if let editedimage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedimage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage  {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImg = selectedImageFromPicker {
            
            profileImg.image = selectedImg
            
            changeProfilePhoto(image: selectedImg)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    
    // Interative with firebase
    
    func changeProfilePhoto(image:UIImage) {
        //
        showLoadingHUD()
        //
        
        let imageName = NSUUID().uuidString
        let storageImgRef = Storage.storage().reference().child("userProfileImg").child("\(imageName).jpg")
        
        if let profileImage = self.profileImg.image,let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
            storageImgRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                if let downloadURL = metadata.downloadURL() {
                    let downloadURLString = String(describing: downloadURL)
                    self.user?.profilePhotoUrl = downloadURLString
                    self.updateUserProfileImg(url: downloadURLString)
                    self.updateTasksUserProfileImg(url: downloadURLString)
                    
                }
            }
            
        }
        
    }
    
    func updateUserProfileImg(url:String) {
        
        let refUser =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("profilePhotoUrl")
        refUser.setValue(url)
    }
    
    
    func updateTasksUserProfileImg(url:String) {
        
        let refTasks  = Database.database().reference().child("Tasks").queryOrdered(byChild: "postedUser").queryEqual(toValue: Auth.auth().currentUser?.uid)
        
        refTasks.observeSingleEvent(of: .value, with: { (snapshot) in
            for task in snapshot.children.allObjects as![DataSnapshot] {
                let taskObject = task.value as? [String:AnyObject]
                let id = taskObject?["id"] as! String
                
                let imageURL =  Database.database().reference().child("Tasks").child(id).child("imageURL")
                imageURL.setValue(url)
                
            }
        })
        //
        hideLoadingHUD()
        //
    }
    
    func nameChange(){
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nameLabelTapped)))
        
    }
    
    @objc func nameLabelTapped(){
        
        deleteFooterView()
        
        self.tableView.scrollToBottom()
        
        
        editingView = UIView(frame: CGRect(x: 0, y: self.view.frame.height-56 , width: self.view.frame.width, height: 56))
        editingView?.backgroundColor = UIColor.groupTableViewBackground
        
        
        seperaterView = UIView(frame: CGRect(x: 0, y: self.view.frame.height-57 , width: self.view.frame.width, height: 1))
        seperaterView?.backgroundColor = .black
        
        
        
        
        changeButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 8, width: 44.00, height: 44.00));
        changeButton?.setTitle("确定", for: .normal)
        changeButton?.layer.cornerRadius = 10
        changeButton?.layer.borderWidth = 1
        changeButton?.backgroundColor = .white
        
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        changeButton?.layer.borderColor = borderColor.cgColor
        changeButton?.setTitleColor(UIColor.blue, for:UIControlState.normal)
        
        changeButton?.addTarget(self, action: #selector(changeName), for: .touchUpInside)
        
        textField = TextField(frame: CGRect(x: 8, y: 8, width: self.view.frame.width - 64, height: 44.00));
        textField?.textAlignment = NSTextAlignment.left
        editingView?.addSubview(textField!)
        
        textField?.placeholder = "我要改名字"
        textField?.backgroundColor = .white
        textField?.delegate = self
        
        textField?.layer.cornerRadius = 10
        textField?.layer.borderWidth = 1
        textField?.layer.borderColor = borderColor.cgColor
        
        editingView?.addSubview(textField!)
        editingView?.addSubview(changeButton!)
        
        self.view.addSubview(seperaterView!)
        self.view.addSubview(editingView!)
        
    }
    
    func profileCellTapped(placeHolderString:String,whichFunction:String){
        
        deleteFooterView()
        
        
        self.tableView.scrollToBottom()
        
        
        editingView = UIView(frame: CGRect(x: 0, y: self.view.frame.height-56 , width: self.view.frame.width, height: 56))
        editingView?.backgroundColor = UIColor.groupTableViewBackground
        
        
        seperaterView = UIView(frame: CGRect(x: 0, y: self.view.frame.height-57 , width: self.view.frame.width, height: 1))
        seperaterView?.backgroundColor = .black
        
        changeButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 8, width: 44.00, height: 44.00));
        changeButton?.setTitle("确定", for: .normal)
        changeButton?.layer.cornerRadius = 10
        changeButton?.layer.borderWidth = 1
        changeButton?.backgroundColor = .white
        
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        changeButton?.layer.borderColor = borderColor.cgColor
        changeButton?.setTitleColor(UIColor.blue, for:UIControlState.normal)
        
        if whichFunction == "changeSkills" {
            changeButton?.addTarget(self, action: #selector(changeSkills), for: .touchUpInside)
        } else if whichFunction == "changeLanguages" {
            changeButton?.addTarget(self, action: #selector(changeLanguages), for: .touchUpInside)
        }
        
        
        textField = TextField(frame: CGRect(x: 8, y: 8, width: self.view.frame.width - 64, height: 44.00));
        textField?.textAlignment = NSTextAlignment.left
        editingView?.addSubview(textField!)
        
        textField?.placeholder = placeHolderString
        textField?.backgroundColor = .white
        
        
        textField?.layer.cornerRadius = 10
        textField?.layer.borderWidth = 1
        textField?.layer.borderColor = borderColor.cgColor
        
        
        
        editingView?.addSubview(textField!)
        editingView?.addSubview(changeButton!)
        
        
        self.view.addSubview(seperaterView!)
        self.view.addSubview(editingView!)
    }
    
    func addSelfDescriptionTextView(){
        
        deleteFooterView()
        
        self.tableView.scrollToBottom()
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        
        
        changeButton = UIButton();
        changeButton?.setTitle("确定", for: .normal)
        changeButton?.layer.cornerRadius = 10
        changeButton?.layer.borderWidth = 1
        changeButton?.backgroundColor = .white
        
        changeButton?.layer.borderColor = borderColor.cgColor
        changeButton?.setTitleColor(UIColor.blue, for:UIControlState.normal)
        
        
        self.view.addSubview(changeButton!)
        
        
        changeButton?.translatesAutoresizingMaskIntoConstraints = false
        changeButton?.addTarget(self, action: #selector(changeDescription), for: .touchUpInside)
        
        textView = UITextView()
        
        textView?.textAlignment = NSTextAlignment.left
        textView?.layer.borderWidth = 0.5
        textView?.layer.borderColor = borderColor.cgColor
        textView?.layer.cornerRadius = 5.0
        textView?.text = "我要改描述"
        textView?.font=UIFont.systemFont(ofSize: 18)
        textView?.textColor = UIColor.lightGray
        textView?.isScrollEnabled = false
        
        self.view.addSubview(textView!)
        
        NSLayoutConstraint(item: changeButton!, attribute: .left, relatedBy: .equal, toItem: textView!, attribute: .right, multiplier: 1, constant: 8).isActive = true
        NSLayoutConstraint(item: changeButton!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: -8).isActive = true
        //                                NSLayoutConstraint(item: textView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant:8).isActive = true
        NSLayoutConstraint(item: changeButton!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -8).isActive = true
        
        NSLayoutConstraint(item: textView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 8).isActive = true
        NSLayoutConstraint(item: textView!, attribute: .right, relatedBy: .equal, toItem: changeButton, attribute: .left, multiplier: 1, constant: -8).isActive = true
        //                                NSLayoutConstraint(item: textView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant:8).isActive = true
        NSLayoutConstraint(item: textView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -8).isActive = true
        
        textView?.translatesAutoresizingMaskIntoConstraints = false
        
        textView?.delegate = self
        
    }
    //changeName func
    
    @objc func changeName() {
        
        if textField?.text != nil {
            nameLabel.text = textField?.text
            user?.displayName = (textField?.text)!
            
            let refUser =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("displayName")
            refUser.setValue((textField?.text)!)
            
            textField?.text = ""
            deleteFooterView()//delete the editing view
        }
        
    }
    
    @objc func changeSkills(){
        
        if textField?.text != nil {
            
            user?.skills.removeAll()
            
            let skills = textField?.text?.components(separatedBy: " ")
            if (skills?.count)! > 0 && (skills?.count)! <= 3 {
                user?.skills = skills!
            } else if (skills?.count)! > 3 {
                user?.skills.append((skills?[0])!)
                user?.skills.append((skills?[1])!)
                user?.skills.append((skills?[2])!)
            }
            tableView.reloadData()
            textField?.text = ""
            let userRef =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("skills")
            userRef.setValue(skills)
            
            deleteFooterView()//delete the editing view
        }
        
    }
    
    @objc func changeLanguages(){
        if textField?.text != nil {
            
            user?.languages.removeAll()
            
            let languages = textField?.text?.components(separatedBy: " ")
            if (languages?.count)! > 0 && (languages?.count)! <= 3 {
                user?.languages = languages!
            } else if (languages?.count)! > 3 {
                user?.languages.append((languages?[0])!)
                user?.languages.append((languages?[1])!)
                user?.languages.append((languages?[2])!)
            }
            tableView.reloadData()
            textField?.text = ""
            let userRef =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("languages")
            userRef.setValue(languages)
            
            deleteFooterView()//delete the editing view
        }
        
    }
    
    @objc func changeDescription(){
        if textView?.text != nil {
            
            user?.selfDescription = ""
            
            let description = textView?.text
            
            user?.selfDescription = description!
            
            tableView.reloadData()
            textView?.text = ""
            let userRef =    Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("description")
            userRef.setValue(description)
            deleteFooterView()//delete the editing view
            
        }
        
    }
    
    func deleteFooterView(){
        
        if let textField =  textField {
            textField.removeFromSuperview()
        }
        
        if let textView = textView {
            
            textView.removeFromSuperview()
        }
        
        if let changeButton = changeButton {
            
            changeButton.removeFromSuperview()
        }
        
        
        if let editingView = editingView {
            editingView.removeFromSuperview()
        }
        
        if let seperaterView =  seperaterView {
            
            seperaterView.removeFromSuperview()
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "backToProfile" {
            
            if let destinationViewController = segue.destination as? profileSettingViewController{
                
                destinationViewController.user = user
                
            }
        }
        
    }
    
    
    //textField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //??
        //        changeName()
        return true
    }
}

extension detailsChangingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "我要改描述"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension detailsChangingViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if user?.skills.count == 0 {
                return 1
            } else {
                return (user?.skills.count)!
            }
        } else  if section == 1{
            if user?.languages.count == 0 {
                return 1
            } else {
                return (user?.languages.count)!
            }
        } else {
            return 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "skillsCell", for: indexPath) as! skillsChangingCell
            
            if user?.skills.count == 0 {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这名用户暂时没有提供任何技能").width + 18 //different from other cells
                cell.skillLabel.text = "这名用户暂时没有提供任何技能"
                
            } else {
                let skill = user?.skills[indexPath.row]
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: skill!).width + 18 //different from other cells
                cell.skillLabel.text = skill
                
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "languagesCell", for: indexPath) as! languagesChangingCell
            
            if user?.languages.count == 0 {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这名用户暂时没有提供任何语言").width + 18
                cell.languageLabel.text = "这名用户暂时没有提供任何语言"
            } else {
                let language = user?.languages[indexPath.row]
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: language!).width + 18
                cell.languageLabel.text = language
            }
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! descriptionChangingCell
            
            if user?.selfDescription == "" {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: "这名用户暂时没有提供任何自我描述").width + 18
                cell.descriptionLabel.text = "这名用户暂时没有提供任何自我描述"
                
            } else {
                cell.bubbleWidthAnchor?.constant = estimateFrameForBubble(text: (user?.selfDescription)!).width + 18
                cell.descriptionLabel.text = user?.selfDescription
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockedUsersCell", for: indexPath) as! blockedUsersCell
            
            if user?.blockedUsers == nil || user?.blockedUsers?.count == 0 {
                
                cell.textLabel?.text = "这名用户暂时没有屏蔽任何用户"
            } else {
                cell.delegate = self
                cell.VC = self
                cell.blockedUsers = self.user?.blockedUsers
                
            }
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            profileCellTapped(placeHolderString: "输入三个以内的技能，用空格隔开", whichFunction: "changeSkills")
            
        } else if indexPath.section == 1 {
            
            profileCellTapped(placeHolderString: "输入三种以内的语言，用空格隔开", whichFunction: "changeLanguages")
        } else if indexPath.section == 2 {
            
            addSelfDescriptionTextView()
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "技能"
            return headerText
        } else if section == 1 {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "语言"
            return headerText
        } else if section == 2 {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "自我描述"
            return headerText
        } else {
            let headerText = UILabel()
            headerText.backgroundColor = UIColor.brown
            headerText.textColor = UIColor.yellow
            headerText.adjustsFontSizeToFitWidth = true
            headerText.textAlignment = .center
            headerText.text = "屏蔽用户"
            return headerText
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    //delete the extra footer view
    func tableView
        (_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}



//custom padding
class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
//protocol for blockedUser Cell
protocol blockedUserDelegate:class {
    func fetchBlockedUser(id:String,completionHandler:@escaping (String,String) -> ())
    //     func userViewTap(id:String)
    func updateDB(array:[String])
    
}

extension detailsChangingViewController:blockedUserDelegate {
    func fetchBlockedUser(id:String,completionHandler:@escaping (String,String) -> ()) {
        Database.database().reference().child("Users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let name = dictionary["displayName"] as! String
                let profilePhotoUrl = dictionary["profilePhotoUrl"] != nil ? dictionary["profilePhotoUrl"] as! String : ""
                completionHandler(name,profilePhotoUrl)
            }
        })
    }
    
    func updateDB(array:[String]){
        let arr = array.count != 0 ? array : nil
        guard let id = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("Users").child(id).child("blockedUsers").setValue(arr)
        
    }
    
    
    //    func userViewTap(id:String){
    //        if let index = self.user?.blockedUsers?.index(of: id) {
    //            user?.blockedUsers?.remove(at: index)
    //            self.tableView.reloadData()
    //            self.tableView.scrollToBottom()
    //        }
    //    }
}


