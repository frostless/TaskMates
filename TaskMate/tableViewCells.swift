//  allTasksCellTableViewCell.swift
//  TaskMate
//
//  Created by Zheng Wei on 6/21/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class allTasksCellTableViewCell: UITableViewCell {
    
    
    let  titleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let  contentLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let  budgetLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let profileImg:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let indicatorButton:UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.black
        button.isHidden = true
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.contentMode = .scaleToFill
        button.backgroundColor = UIColor.groupTableViewBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addSubview(profileImg)
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(budgetLabel)
        addSubview(indicatorButton)
        
        //x,y,w,h
        profileImg.leftAnchor.constraint(equalTo: self.leftAnchor,constant:8).isActive = true
        profileImg.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImg.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImg.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        //x,y,w,h
        
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor,constant:15).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: profileImg.rightAnchor,constant:8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-60).isActive = true

        
        //x,y,w,h
        
        contentLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant:-15).isActive = true
        contentLabel.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-50).isActive = true
        
         //x,y,w,h
        indicatorButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-8).isActive = true
          indicatorButton.bottomAnchor.constraint(equalTo: contentLabel.bottomAnchor).isActive = true
        
        
        //x,y,w,h
        
        budgetLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        budgetLabel.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-8).isActive = true
        

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// Custom Cells
class offersCell:UITableViewCell{
    
    weak var delegate:cellDelegate?
    
    var user:Users?
    
    @IBOutlet weak var offeredUserDisplayName: UILabel!
    @IBOutlet weak var offeredUserRatingImg: UIImageView!
    @IBOutlet weak var offeredUserProfileImg: UIImageView!
    
    @IBOutlet weak var offeredTime: UILabel!
    
    @IBOutlet weak var bidSuccessfulRate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        offeredUserProfileImg.translatesAutoresizingMaskIntoConstraints = true
        offeredUserProfileImg.layer.cornerRadius = 30
        offeredUserProfileImg.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(segueToTaskerDetails))
        offeredUserProfileImg.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func segueToTaskerDetails(sender: UITapGestureRecognizer) {
        guard let user = user else {
            return
        }
        self.delegate?.offersSegueToTaskerDetails(data: user)
        
    }
    
}


class commentsCell:UITableViewCell{
    
    var comment:Comments?
    var userID:String?//Commenter
    weak var delegate:cellDelegate?
    var visitorID:String?//app visitor
    var user:Users?
    
    @IBOutlet weak var expandRepliesButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBody: UILabel!
    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var commentedTaskerProfilImg: UIImageView!
    @IBOutlet weak var commentedTaskerDisplayName: UILabel!
    @IBOutlet weak var commentedTime: UILabel!
    @IBOutlet weak var commentReplyBtn: UIButton!
    @IBOutlet weak var commentLikeBtn: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(segueToTaskerDetails))
        commentedTaskerProfilImg.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func segueToTaskerDetails(sender: UITapGestureRecognizer) {
        
        //        delegate?.getCommenter(id: userID!, completionHandler: { (user) in
        //            self.delegate?.commentsSegueToTaskerDetails(data: user)
        //        })
        guard let user = user else {
            return
        }
        delegate?.commentsSegueToTaskerDetails(data: user)
    }
    
    
    @IBAction func expandRepliesButtonTapped(_ sender: Any) {
        
        guard let comment = comment else {
            return
        }
        
        if comment.isExpanded {
            //the replies property of my Comment model is an array of Commment objects
            delegate?.hideCommentsReplies(parentComment: comment, replies:comment.replies)
            comment.isExpanded = false
        } else {
            delegate?.showCommentsReplies(parentComment: comment, replies:comment.replies)
            comment.isExpanded = true
        }
    }
    
    @IBAction func replyToComment(_ sender: Any) {
        guard let comment = comment else {
            return
        }
        self.delegate?.segueToCommentReply(data: comment)
    }
    
    
    @IBAction func commentLikeBtnPressed(_ sender: Any) {
        
        let commentRef = Database.database().reference().child("Comments")
        
        let id = (delegate?.likeComment())!
        
        guard let visitorID = visitorID,let comment = comment else {
            return
        }
        
        var numberOfLikes = comment.numberOfLikes
        // determine which comment level to update
        if comment.parentComment == "" {
            // parent comment update begins here
            if numberOfLikes == nil || numberOfLikes?.count == 0 {
                //no likes yet
                commentRef.child(id).child(comment.id).child("numberOfLikes").setValue([visitorID])
                delegate?.toggleLikeComment(comment: comment,id:visitorID)
            } else {
                //likes exit
                if (numberOfLikes?.contains(visitorID))!{
                    //visitor made like before,so remove
                    let index = numberOfLikes?.index(of: visitorID)
                    numberOfLikes?.remove(at: index!)
                    commentRef.child(id).child(comment.id).child("numberOfLikes").setValue(numberOfLikes)
                    delegate?.toggleLikeComment(comment: comment,id:visitorID)
                } else {
                    //visitor did not made like before,so append
                    numberOfLikes?.append(visitorID)
                    commentRef.child(id).child(comment.id).child("numberOfLikes").setValue(numberOfLikes)
                    delegate?.toggleLikeComment(comment: comment,id:visitorID)
                }
            }
            //parent comment update ends here
        } else {
            //replies comment update begins
            if numberOfLikes == nil || numberOfLikes?.count == 0 {
                commentRef.child(id).child(comment.parentComment).child("replies").child(comment.id).child("numberOfLikes").setValue([visitorID])
                delegate?.toggleLikeComment(comment: comment,id:visitorID)
            } else {
                //likes exit
                if (numberOfLikes?.contains(visitorID))!{
                    //visitor made like before,so remove
                    let index = numberOfLikes?.index(of: visitorID)
                    numberOfLikes?.remove(at: index!)
                    commentRef.child(id).child(comment.parentComment).child("replies").child(comment.id).child("numberOfLikes").setValue(numberOfLikes)
                    delegate?.toggleLikeComment(comment: comment,id:visitorID)
                }else {
                    //visitor did not made like before,so append
                    numberOfLikes?.append(visitorID)
                    commentRef.child(id).child(comment.parentComment).child("replies").child(comment.id).child("numberOfLikes").setValue(numberOfLikes)
                    delegate?.toggleLikeComment(comment: comment,id:visitorID)
                }
            }
            //replies comment update ends here
        }
        
    }
    
}

class commentToReplyCell:UITableViewCell{
    
    weak var delegate:CommentReplyCellDelegate?
    
    var comment = Comments("comment")
    var visitorID:String?
    
    @IBOutlet weak var expandRepliesButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBody: UILabel!
    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var commentedTaskerProfilImg: UIImageView!
    @IBOutlet weak var commentedTaskerDisplayName: UILabel!
    @IBOutlet weak var commentedTime: UILabel!
    @IBOutlet weak var commentLikeBtn: UIButton!
    
    
    @IBAction func commentLikeBtnPressed(_ sender: Any) {
        
        let commentRef = Database.database().reference().child("Comments")
        let id = (delegate?.likeComment())!
        
        guard let visitorID = visitorID else {
            return
        }
        
        var numberOfLikes = comment.numberOfLikes
        
        if numberOfLikes == nil || numberOfLikes?.count == 0 {
            //no likes yet
            commentRef.child(id).child(comment.id).child("numberOfLikes").setValue([visitorID])
            delegate?.reloadTblView(comment: comment,id:visitorID)
        } else {
            //likes exit
            if (numberOfLikes?.contains(visitorID))!{
                //visitor made like before,so remove
                let index = numberOfLikes?.index(of: visitorID)
             numberOfLikes?.remove(at: index!)
                commentRef.child(id).child(comment.id).child("numberOfLikes").setValue(numberOfLikes)
                delegate?.reloadTblView(comment: comment,id:visitorID)
            } else {
                //visitor did not made like before,so append
                 numberOfLikes?.append(visitorID)
                commentRef.child(id).child(comment.id).child("numberOfLikes").setValue(numberOfLikes)
               delegate?.reloadTblView(comment: comment,id:visitorID)
            }
        }
     
    }
}



class customMessageCell:UITableViewCell {
    
    weak var msgDetailsViewController:msgDetailsViewController?
    
    var message:Messages?
    
    let activityIndicatorView:UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton:UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "playButton")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleVieoPlay), for: .touchUpInside)
        return button
    }()
    
    var playerLayer:AVPlayerLayer?
    var player:AVPlayer?
    
    @objc func handleVieoPlay(){
        if let videoUrl = message?.videoUrl,let url = URL(string: videoUrl){
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubble.bounds
            bubble.layer.addSublayer(playerLayer!)
            
            player?.play()
            
            activityIndicatorView.startAnimating()
            
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let msgReciverProfileImg:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let msgSenderProfileImg:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let msgBody:UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
//        label.backgroundColor = UIColor(rgb:0x94D8FF)
        label.textColor=UIColor.black
        label.font=UIFont.systemFont(ofSize: 18)
        return label
    }()
    let timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bubble:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb:0x94D8FF)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5.0
        return view
    }()
    
    lazy var messageImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZoom)))
        return imageView
    }()
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    var bubbleHeightAnchor:NSLayoutConstraint?
    var bubbleRightAnchor:NSLayoutConstraint?
    var bubbleLeftAnchor:NSLayoutConstraint?
    
    @objc func handleImageZoom(tapGestrue:UIGestureRecognizer){
        
        //dont perform zoom when the image is actually a video
        if message?.videoUrl != "" {
            return
        }
        
        //dont perform a lot of logic in a view class
        
        if let imageView = tapGestrue.view as? UIImageView {
            self.msgDetailsViewController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
        
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(msgReciverProfileImg)
        addSubview(msgSenderProfileImg)
        addSubview(bubble)
        addSubview(msgBody)
        addSubview(timeLabel)
        bubble.addSubview(messageImageView)
        //         bubble.addSubview(msgBody)
        
        
        
        //x,y,w,h
        
        messageImageView.leftAnchor.constraint(equalTo: bubble.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubble.topAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubble.heightAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubble.widthAnchor).isActive = true
        
        bubble.addSubview(playButton)
        
        //x.y.w,h
        
        playButton.centerXAnchor.constraint(equalTo: bubble.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubble.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubble.addSubview(activityIndicatorView)
        
        //x.y.w,h
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubble.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubble.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //ios 9 constraints anchors
        msgReciverProfileImg.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 8).isActive = true
        msgReciverProfileImg.topAnchor.constraint(equalTo: self.topAnchor,constant : 28).isActive = true
        msgReciverProfileImg.widthAnchor.constraint(equalToConstant: 48).isActive = true
        msgReciverProfileImg.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //x,y,width,height anchors
        
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor,constant:8).isActive = true
        timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        //x,y,width,height anchors
        
        bubbleRightAnchor = bubble.rightAnchor.constraint(equalTo:msgSenderProfileImg.leftAnchor, constant: -8)
        
        bubbleRightAnchor?.isActive = true
        
        bubbleLeftAnchor = bubble.leftAnchor.constraint(equalTo:msgReciverProfileImg.rightAnchor, constant: 8)
        
        bubbleLeftAnchor?.isActive = false
        
        bubbleWidthAnchor =  bubble.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleHeightAnchor = bubble.heightAnchor.constraint(equalToConstant: 80)
        bubbleHeightAnchor?.isActive = true
        
        bubble.topAnchor.constraint(equalTo: msgReciverProfileImg.topAnchor,constant:10).isActive = true
        //        bubble.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant:-8).isActive = true
        
        
        //x,y,width,height anchors
        
        
        msgBody.rightAnchor.constraint(equalTo: bubble.rightAnchor, constant:-5).isActive = true
        msgBody.leftAnchor.constraint(equalTo: bubble.leftAnchor, constant: 8).isActive = true
        msgBody.topAnchor.constraint(equalTo:  bubble.topAnchor,constant:8).isActive = true
        msgBody.bottomAnchor.constraint(equalTo: bubble.bottomAnchor,constant:-8).isActive = true
        
        
        //x,y,width,height anchors
        
        
        msgSenderProfileImg.topAnchor.constraint(equalTo: msgReciverProfileImg.topAnchor).isActive = true
        msgSenderProfileImg.widthAnchor.constraint(equalToConstant: 48).isActive = true
        msgSenderProfileImg.heightAnchor.constraint(equalToConstant: 48).isActive = true
        msgSenderProfileImg.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



class userCell:UITableViewCell {
    
    var message:Messages?{
        didSet{
            
            setupNameAndProfileIma()
            
            detailTextLabel?.text = message?.content
            
            //for image
            
            if message?.content == "" && message?.imageUrl != "" {
                detailTextLabel?.text = "[图片]"
            }
            if message?.content == "" && message?.videoUrl != "" {
                detailTextLabel?.text = "[视频]"
            }
            
            guard let messageTime = message?.timeStamp.doubleValue else {
              return
            }
            //for time
            if NSDate().timeIntervalSince1970 - 86400 > messageTime {
                
                let timeStampDate = Date(timeIntervalSince1970:(messageTime))
               timeLabel.text = timeAgoSinceDate(timeStampDate)
            } else {
                
                let timeStampDate = Date(timeIntervalSince1970:(messageTime))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
            }
            
        }
    }
    
    
    private func setupNameAndProfileIma(){
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("Users").child(id)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as?[String:AnyObject]
                {
                    self.textLabel?.text = dictionary["displayName"] as? String
                    
                    self.profileImageView.image = UIImage(named:"profilePhoto")
                    
                    if let url = dictionary["profilePhotoUrl"] {
                        let imgUrl = URL(string:url as! String)
                        
                        //                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString:imgUrl!)
                        
                        self.profileImageView.kf.setImage(with: imgUrl)
                    }
                    
                }
                
            })
            
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        textLabel?.frame = CGRect(x:64,y:textLabel!.frame.origin.y - 2,width:self.frame.width - 172,height:textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x:64,y:detailTextLabel!.frame.origin.y + 2,width:self.frame.width - 64 ,height:detailTextLabel!.frame.height)
        
    }
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let timeLabel:UILabel = {
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        //ios 9 constraints anchors
        //x,y,width,height anchors
        
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //x,y,width,height anchors
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor,constant:18).isActive = true
//        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



class reviewsToTaskerCell:UITableViewCell {
    
    var reviewLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor=UIColor.black
        label.font=UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    var bubble:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.green
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5.0
        return view
    }()
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"profilePhoto")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    //    var bubbleHeightAnchor:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(profileImageView)
        addSubview(bubble)
        addSubview(timeLabel)
        addSubview(reviewLabel)
        addSubview(nameLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8.0).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: bubble.leftAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 3).isActive = true
       nameLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        
        bubble.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8.0).isActive = true
        
        bubbleWidthAnchor =  bubble.widthAnchor.constraint(equalToConstant: 100)
        bubbleWidthAnchor?.isActive = true
        
        bubble.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 3.0).isActive = true
        bubble.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0).isActive = true
        
        reviewLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 8.0).isActive = true
        reviewLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -8.0).isActive = true
        reviewLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8.0).isActive = true
        reviewLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8.0).isActive = true

    }
    
}

class skillsChangingCell:UITableViewCell {
    
    var skillLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0
        label.textColor=UIColor.black
        label.font=UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    var bubble:UIView = {
        
        let view = UIView()
//        view.backgroundColor = UIColor.green
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5.0
        return view
    }()
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    //    var bubbleHeightAnchor:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.contentView.addSubview(bubble)
        
        bubble.addSubview(skillLabel)
        
        bubble.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8.0).isActive = true
        
        bubbleWidthAnchor =  bubble.widthAnchor.constraint(equalToConstant: 100)
        bubbleWidthAnchor?.isActive = true
        
        bubble.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0).isActive = true
        bubble.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0).isActive = true
        
        skillLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 8.0).isActive = true
        skillLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -8.0).isActive = true
        skillLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8.0).isActive = true
        skillLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8.0).isActive = true
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        skillLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
}

class languagesChangingCell:UITableViewCell {
    
    var languageLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0
        label.textColor=UIColor.black
        label.font=UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    var bubble:UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.green
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5.0
        return view
    }()
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    //    var bubbleHeightAnchor:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.contentView.addSubview(bubble)
        
        bubble.addSubview(languageLabel)
        
        bubble.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8.0).isActive = true
        
        bubbleWidthAnchor =  bubble.widthAnchor.constraint(equalToConstant: 100)
        bubbleWidthAnchor?.isActive = true
        
        bubble.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0).isActive = true
        bubble.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0).isActive = true
        
        languageLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 8.0).isActive = true
        languageLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -8.0).isActive = true
        languageLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8.0).isActive = true
        languageLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8.0).isActive = true
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        languageLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
}

class descriptionChangingCell:UITableViewCell {
    
    var descriptionLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0
        label.textColor=UIColor.black
        label.font=UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    var bubble:UIView = {
        
        let view = UIView()
//        view.backgroundColor = UIColor.green
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5.0
        return view
    }()
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    //    var bubbleHeightAnchor:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.contentView.addSubview(bubble)
        
        bubble.addSubview(descriptionLabel)
        
        bubble.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8.0).isActive = true
        
        bubbleWidthAnchor =  bubble.widthAnchor.constraint(equalToConstant: 100)
        bubbleWidthAnchor?.isActive = true
        
        bubble.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0).isActive = true
        bubble.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0).isActive = true
        
        descriptionLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 8.0).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -8.0).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8.0).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8.0).isActive = true
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
}

class blockedUsersCell:UITableViewCell {
    
    weak var delegate:blockedUserDelegate?
    weak var VC:detailsChangingViewController?
    var blockedUsers:[String]? {
        didSet{
            guard let blockedUsers = blockedUsers else {
                return
            }
            if self.subviews.count != 0 {
                for view in self.subviews{
                    if view is UIImageView || view is UILabel{
                        view.removeFromSuperview()
                    }
                }
            }
            let numInOneLine =  Int((self.frame.width - 8)/56)
            //offset for each view left anchor
            
            let gapOffSet = (Int(self.frame.width) - (56*numInOneLine + 8))/numInOneLine - 1
            var numCounter = 0
            var lineCounter = 1
            // line of view in the cell
            let numOfLine = Int(ceilf((Float(blockedUsers.count)/Float(numInOneLine))))
            
            for id in blockedUsers{
                //increment numCounter
                numCounter += 1
                //create masterpiece of view
                let view = UIImageView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.layer.cornerRadius = 24
                view.layer.masksToBounds = true
                view.image = UIImage(named:"profilePhoto")
                view.isUserInteractionEnabled = true
                let tapGesture = blockedUserTapGesture(target: self, action: #selector(self.viewTap(sender:)))
                tapGesture.id = id
                view.addGestureRecognizer(tapGesture)
                
                addSubview(view)
                
                //create name lable
                
                let nameLabel = UILabel()
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                nameLabel.text = "名字"
                nameLabel.textAlignment = .center
                nameLabel.font = UIFont.boldSystemFont(ofSize: 10)
                addSubview(nameLabel)
                
                nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                nameLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
                nameLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                nameLabel.topAnchor.constraint(equalTo: view.bottomAnchor,constant:8).isActive = true
                
                //get the user from db
                delegate?.fetchBlockedUser(id: id, completionHandler: { (name, photoUrl) in
                    nameLabel.text = name
                    if photoUrl != "" {
                        let imgUrl = URL(string: (photoUrl))
                        view.kf.setImage(with: imgUrl)
                    }
                })
                
                view.widthAnchor.constraint(equalToConstant: 48).isActive = true
                view.heightAnchor.constraint(equalToConstant: 48).isActive = true
                
                let topOffSet = lineCounter == 1 ? CGFloat(8) : CGFloat(76*(lineCounter-1) + 8)
                
                view.topAnchor.constraint(equalTo: self.topAnchor,constant:topOffSet).isActive = true
                
                //set bottomAnchor for the last line
                if lineCounter == numOfLine {
                    nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant:-8).isActive = true
                }
                
                if  numCounter == 1 || numCounter % numInOneLine == 1 {
                    view.leftAnchor.constraint(equalTo: self.leftAnchor,constant:8+CGFloat(gapOffSet)).isActive = true
                } else {
                    //get the left offset
                    let const = numCounter - (numInOneLine*(lineCounter-1))
                    let offSet = CGFloat(56*const - 48 + const*gapOffSet)
                    view.leftAnchor.constraint(equalTo: self.leftAnchor,constant:offSet).isActive = true
                }
                
                if numCounter % numInOneLine == 0 {
                    //increment lineCounter
                    lineCounter += 1
                }
            }
        }
    }
    
    @objc func viewTap(sender: blockedUserTapGesture){
        let alertController = UIAlertController(title: "请求确认", message: "您确认要取消屏蔽这个用户吗？取消屏蔽后可以重新看到该用户发布的任务和聊天信息", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "确定", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            guard let id = sender.id else {
                return
            }
            
            if let index = self.VC?.user?.blockedUsers?.index(of: id) {
                self.self.VC?.user?.blockedUsers?.remove(at: index)
            }
            
            if self.VC?.user?.blockedUsers?.count == 0 {
                self.blockedUsers = []
            }
            self.self.VC?.tableView.reloadData()
            self.VC?.tableView.scrollToBottom()
            
            //update db
            if let arr = self.VC?.user?.blockedUsers{
                self.delegate?.updateDB(array: arr)
            }
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        VC?.present(alertController, animated: true, completion: nil)
        
    }
    
}

