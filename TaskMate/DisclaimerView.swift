//
//  DisclaimerView.swift
//  TaskMate
//
//  Created by Wei Zheng on 28/9/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit

class DisclaimerView:UIView {
    
    weak var vc:SignInViewController?
    
    let titleLabel:UILabel = {
        let label = UILabel()
        label.text = "澳洲百事通使用条款"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
        
    }()
    
    let textContainer:UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        textView.backgroundColor = UIColor.groupTableViewBackground
        textView.text = "1:澳洲百事通是一个网上任务分享平台，用户分享的任务必须是技能型任务，即完成任务需要一定专业技能，而非无任何技能附加的任务。如果用户发布了非技能型任务，澳洲百事通有权将任务删除，如遇严重违规者，澳洲百事通有权禁止发布任务的用户登录。\n2:发布任务时请务必根据所选的任务分类进行任务描述，(比如：选择IT分类时任务描述必须与IT相关)如有不按分类要求进行描述者，澳洲百事通有权删除任务。\n3:禁止发布色情，暴力，淫秽或带有政治背景的内容，如有发布，澳洲百事通有权将内容删除，严重违规者将被禁止登陆。\n4:如在浏览内容时看到有以上提及的内容不当的情形，用户可以进入具体任务并使用'举报'功能，澳洲百事通会在收到举报24小时内对内容进行审核并进行相应处理。\n5:禁止使用澳洲百事通的聊天社交功能对用户进行骚扰，跟踪或其他不当的行为，如有发生，被骚扰用户可以对骚扰用户进行屏蔽，澳洲百事通也会视情况严重程度进行相应处理。\n6:用户点击下面按钮将视为遵守这个使用条款，并会依据条款使用该平台。"
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    let radioButton:UIButton = {
        let button = RadioButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action:#selector(radioButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    let textLabel:UILabel = {
        let label = UILabel()
        label.text = "点击接受条款"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(titleLabel)
        addSubview(textContainer)
        addSubview(radioButton)
        addSubview(textLabel)
        
        
        //
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
        if #available(iOS 11.0, *) {
            titleLabel.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,constant:20).isActive = true
        } else {
            titleLabel.topAnchor.constraint(
                equalTo: self.topAnchor,constant:30).isActive = true
        }
        
        
        //
        textContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textContainer.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true

            textContainer.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,constant:8).isActive = true
        
        //
       
        radioButton.topAnchor.constraint(equalTo: textLabel.topAnchor).isActive = true
        radioButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        radioButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        radioButton.rightAnchor.constraint(equalTo: textLabel.leftAnchor,constant:-8).isActive = true
        
        //
        textLabel.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-8).isActive = true
        textLabel.topAnchor.constraint(equalTo: textContainer.bottomAnchor,constant:8).isActive = true
    }
    
    @objc private func radioButtonIsClicked(sender: RadioButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            textLabel.text = "条款接受成功"
                self.vc?.view = self.vc?.selfView
//                self.vc?.selfView = nil
          
//            UserDefaults.standard.set(true, forKey: "isDisclaimerShown")
            
        } else{
            textLabel.text = "点击接受条款"
        }
    }
    
}
