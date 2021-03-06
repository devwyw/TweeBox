//
//  TweetWithPicTableViewCell.swift
//  TweeBox
//
//  Created by 4faramita on 2017/8/8.
//  Copyright © 2017年 4faramita. All rights reserved.
//

import UIKit
import Kingfisher
import VisualEffectView


class TweetWithPicTableViewCell: TweetTableViewCell {
    
    private var totalMediaNum: Int!
    
    private var images = [UIImageView?]()
    
    @IBAction func imageTapped(byReactingTo: UIGestureRecognizer) {
        
        let touchPoint = byReactingTo.location(in: self.tweetPicContent)
        let xBound = self.tweetPicContent.bounds.maxX
        let yBound: CGFloat
        if totalMediaNum == 2 || totalMediaNum == 3 {
            yBound = self.tweetPicContent.bounds.maxY / 2
        } else {
            yBound = self.tweetPicContent.bounds.maxY
        }
        
        let whichMedia = (touchPoint.x <= xBound, touchPoint.y <= yBound)
        
        switch whichMedia {
        case (true, true):  // up left
            mediaIndex = 0
        case (false, true):  // up right
            mediaIndex = totalMediaNum >= 2 ? 1 : 0
        case (true, false):  // down left
            mediaIndex = totalMediaNum == 4 ? 2 : 0
        case (false, false):  // down right
            mediaIndex = ((totalMediaNum == 4) ? 3 : ((totalMediaNum == 3) ? 2 : ((totalMediaNum == 2) ? 1 : 0)))
        }
        
        
        guard let section = section, let row = row, let mediaIndex = mediaIndex else { return }
        delegate?.imageTapped(section: section, row: row, mediaIndex: mediaIndex, media: (tweet?.entities?.media)!)
    }
    
    
    @IBOutlet weak var tweetPicContent: UIImageView!
    
    @IBOutlet weak var secondPic: UIImageView!
    
    @IBOutlet weak var thirdPic: UIImageView!
    
    @IBOutlet weak var fourthPic: UIImageView!
        
    private func setPic(at position: Int, of total: Int) {
        
        totalMediaNum = total
        
        let media = tweet!.entities!.media!
        
        images = [tweetPicContent, secondPic, thirdPic, fourthPic]
        
        var ratio: CGFloat {
            if (total == 2) || (total == 3 && position == 0) {
                return Constants.thinAspectRatio
            } else {
                return Constants.normalAspectRatio
            }
        }
        
        let pic = media[position]
        let tweetPicURL = pic.mediaURL
        
        if pic.type != "photo" {
            
            let visualEffectView = VisualEffectView(frame: tweetPicContent.bounds)
            visualEffectView.blurRadius = 2
            visualEffectView.colorTint = .white
            visualEffectView.colorTintAlpha = 0.2
            tweetPicContent.addSubview(visualEffectView)
            
            let play = UIImageView(image: UIImage(named: "play_video"))
            tweetPicContent.addSubview(play)
            play.snp.makeConstraints { (make) in
                make.center.equalTo(tweetPicContent)
                make.height.equalTo(32)
                make.width.equalTo(32)
            }
            
            if pic.type == "animated_gif" {
                let gif = UIImageView(image: UIImage(named: "play_gif"))
                tweetPicContent.addSubview(gif)
                gif.snp.makeConstraints { (make) in
                    make.trailing.equalTo(tweetPicContent).offset(-10)
                    make.bottom.equalTo(tweetPicContent)
                    make.height.equalTo(32)
                    make.width.equalTo(32)
                }
            }
        }
        
        let cutSize = pic.getCutSize(with: ratio, at: .small)
        let cutPoint = CGPoint(x: 0.5, y: 0.5)
        // means cut from middle out
        
        // Kingfisher
        let placeholder = UIImage(named: "picPlaceholder")!.kf.image(withRoundRadius: Constants.picCornerRadius, fit: cutSize)
        
        let processor = CroppingImageProcessor(size: cutSize, anchor: cutPoint)
        
        if let picView = images[position] {
//            picView.kf.indicatorType = .activity
            picView.kf.setImage(
                with: tweetPicURL,
                placeholder: placeholder,
                options: [
                    .transition(.fade(Constants.picFadeInDuration)),
                    .processor(processor)
                ]
            )
            picView.layer.borderWidth = 1
            picView.layer.borderColor = UIColor.white.cgColor
            picView.cutToRound(radius: Constants.picCornerRadius)
            
            
            // tap to segue
            let ptap = UITapGestureRecognizer(
                target: self,
                action: #selector(imageTapped(byReactingTo:))
            )
            ptap.numberOfTapsRequired = 1
            picView.addGestureRecognizer(ptap)
            picView.isUserInteractionEnabled = true
        }
    }
    
    override func updateUI() {
        
        super.updateUI()
        
        if let total = tweet?.entities?.media?.count {
            for i in 0..<total {
                setPic(at: i, of: total)
            }
        }
    }
}
