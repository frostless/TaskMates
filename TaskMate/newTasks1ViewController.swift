//
//  newTasks1ViewController.swift
//  TaskMate
//
//  Created by Zheng Wei on 5/23/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit

class newTasks1ViewController: UIViewController {
    
    var task: Tasks?
    
    let datePicker = UIDatePicker()

    @IBOutlet weak var dateTextField: UITextField!
    
    @IBAction func confirmButton(_ sender: Any) {
        if dateTextField.text != "" {
        let now = Date()
        let taskDate = datePicker.date
        let order = Calendar.current.compare(now, to: taskDate, toGranularity: .day)
        task?.createdDate = now
       
        switch order {
        case .orderedDescending:
            showAlert(withTitle: "出错了..", message: "完成日期不能早于今天.")
        case .orderedAscending:
            self.performSegue(withIdentifier: "toTasks2", sender: self)
        case .orderedSame:
            self.performSegue(withIdentifier: "toTasks2", sender: self)
            }
        } else {
             showAlert(withTitle: "出错了..", message: "请选择日期.")
          }
        
        
        /*
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = formatter.string(from: today)
        let targetDate = formatter.string(from: datePicker.date)
        if currentDate  == targetDate {
        print(currentDate)
        }
        
        
        
        if ( today > datePicker.date.addingTimeInterval(30)) {
            // create the alert
            let alert = UIAlertController(title: "出错了。。", message: "完成日期不能早于今天。", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.performSegue(withIdentifier: "toTasks2", sender: self)
          
        }
 */
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        
        /*
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = UIDatePickerMode.date
        
        datePicker.addTarget(self, action:#selector(newTasks1ViewController.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        dateTextField.inputView = datePicker
 */
        
        // set textfield placeholder' image
        let attachmentIma = NSTextAttachment(data: nil, ofType: nil)
        attachmentIma.image = UIImage(named: "calendar")
        let attachmentString = NSAttributedString(attachment: attachmentIma)
        let attributedText = NSMutableAttributedString(attributedString: attachmentString)
        let dateString = NSAttributedString(string: "请输入日期")
        attributedText.append(dateString)
        dateTextField.attributedPlaceholder = attributedText
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDatePicker(){
        
        datePicker.datePickerMode = .date
        datePicker.locale = NSLocale.init(localeIdentifier: "en_AU") as Locale
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
         let doneButton: UIBarButtonItem = UIBarButtonItem(title: "确定", style: .done, target: self, action:#selector(donePressed))
         let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action:#selector(cancelPressed))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton,spacer,doneButton],animated:false)
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
    }
    
    @objc func donePressed(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        dateTextField.text = formatter.string(from:datePicker.date)
        task?.dueDate = datePicker.date
        self.view.endEditing(true)
        
    }
    
    @objc func cancelPressed(){
    
        self.view.endEditing(true)
        
    }
    
 
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        /*
        if (dateTextField.text != "" ) {
        task?.dueDate = dateTextField.text!
        }
        */
        // Set the task to be passed to myTasksViewController after the segue.
      
        if let destinationViewController = segue.destination as? newTasks2ViewController {
            destinationViewController.task = task
        }
    }
    

}
