//
//  newTasksViewController.swift
//  TaskMate
//
//  Created by Zheng Wei on 5/20/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit

import os.log

class newTasksViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //properties:
    var taskType:String?
    
    //IB Outlest
    @IBOutlet weak var taskTitle: UITextField!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var saveTask: UIButton!
    @IBOutlet weak var onlineOrNot: UISegmentedControl!
    @IBOutlet weak var onlinelocation: UILabel!
    @IBOutlet weak var onlineTextField: UITextField!
    
    //IB Actions
    @IBAction func confirmButton(_ sender: Any) {
        if ((taskTitle.text?.characters.count)! < 5) {
            showAlert(withTitle: "出错了。。", message: "任务标题字数少于5.")
            
        } else if ((taskDescription.text?.characters.count)! < 20) {
            showAlert(withTitle: "出错了。。", message: "任务描述字数少于20.")
            
        } else{
            
            if let taskTitleText = taskTitle.text,let taskDescriptionText = taskDescription.text {
                let listOfSwearWords = ["鸡巴", "你妈", "我操", "傻逼", "操你妈", "我日"]
                 let tasktTitleBool =  self.containsSwearWord(text: taskTitleText, swearWords: listOfSwearWords)
                let taskDescriptionBool =  self.containsSwearWord(text: taskDescriptionText, swearWords: listOfSwearWords)
                if tasktTitleBool||taskDescriptionBool{
                    showAlert(withTitle: "粗错了..", message: "系统在您的任务中发现有敏感词，请重新输入")
                    return
                }
            }
          
            
           
        self.performSegue(withIdentifier: "toTasks1", sender: self)
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // create a task object to be passed to myTasksViewController or allTasksViewController
    var task: Tasks?
    var taskLocation:String?
    var taskLatitude:Double?
    var taskLongitude:Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiConfigure()
    }
    
    //UI configure
    
    func uiConfigure(){
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        taskDescription.layer.borderWidth = 0.5
        taskDescription.layer.borderColor = borderColor.cgColor
        taskDescription.layer.cornerRadius = 5.0
        
        onlineOrNot.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        // Do any additional setup after loading the view.
        
        //default
        onlinelocation.isHidden = true
        onlineTextField.isHidden = true
        
        onlineTextField.delegate = self
        
        //for keyboard
         self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        //for task title place hoder
        
        guard let taskType = self.taskType else {
            return
        }
        
        switch taskType {
//        case "others":taskTitle.placeholder = "请输入任务标题 提示:必须是其他技能型任务"
        case "cleaning": taskTitle.placeholder = "请输入任务标题 比如：我想找个人帮我打扫房间"
        case "travelling": taskTitle.placeholder = "请输入任务标题 比如：我想找个驴伴一起去玩"
        case "moving": taskTitle.placeholder = "请输入任务标题 比如：我想找个人帮我搬家"
        case "it":  taskTitle.placeholder = "请输入任务标题 比如：我想找个人帮我做个app"
        case "buyingAgent": taskTitle.placeholder = "请输入任务标题 比如：我想找个人代购化妆品"
        case "renting": taskTitle.placeholder = "请输入任务标题 比如：我想在市中心找间房"
        default:showAlert(withTitle: "粗错了", message: "任务类型选择错误")
        }
        
    }
    
    //Action:
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            onlinelocation.isHidden = true
            onlineTextField.isHidden = true
        } else {
            onlinelocation.isHidden = false
            onlineTextField.isHidden = false
        }
        
    }
    
    
    
    // MARK: - Navigation
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "toLocation", sender: self)
        
        return false
        
    }

    @IBAction func backToStepOne(segue:UIStoryboardSegue) {
        
     onlineTextField.text = taskLocation
        
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toTasks1" {
        // Configure the destination view controller only when the "确定" button is pressed.
       /* 
         guard let button = sender as? UIButton, button === saveTask else {
            os_log("The 确定 button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
       */
        let title = taskTitle.text ?? "" //not optional
        let desc = taskDescription.text ?? "" //not optional
        
        // Set the task to be passed to myTasksViewController after the segue.
        task = Tasks(title: title,desc: desc)
            if taskLatitude != nil {
        task?.latitude = taskLatitude!
        task?.longitude = taskLongitude!
        task?.location = taskLocation!
            }
        
        if onlineOrNot.selectedSegmentIndex == 0 {
            task?.isOnline = true
            
        } else {
            task?.isOnline = false
            
        }
        
        if let destinationViewController = segue.destination as? newTasks1ViewController {
            destinationViewController.task = task
        }
            
        }
    }
    

}
