//
//  AcceptOfferCell.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 6/29/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation

class AcceptOfferCell: UITableViewCell {
    let mainView: UIView = UIView()
    let makeOfferLabel: UILabel = UILabel()
    let counterBtn: UIButton = UIButton()
    let acceptBtn: UIButton = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        
        mainView.frame = CGRectMake(0, 0, self.frame.width, 80)
        //mainView.backgroundColor = UIColor.redColor()
        
        makeOfferLabel.frame = CGRectMake(0,15,mainView.frame.width,25)
        makeOfferLabel.backgroundColor = UIColor.clearColor()
        makeOfferLabel.font = UIFont(name: "Avenir-Black", size: 14)
        makeOfferLabel.textAlignment = .Center
        makeOfferLabel.textColor = UIColor.darkGrayColor()
        
        counterBtn.frame = CGRectMake(20,45,mainView.frame.width/2-25,30)
        counterBtn.setTitle("COUNTER", forState: UIControlState.Normal)
        counterBtn.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        counterBtn.tintColor = UIColor.whiteColor()
        counterBtn.backgroundColor = UIColor.redColor()
        
        acceptBtn.frame = CGRectMake(5+mainView.frame.width/2,45,mainView.frame.width/2-25,30)
        acceptBtn.setTitle("ACCEPT", forState: UIControlState.Normal)
        acceptBtn.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        acceptBtn.tintColor = UIColor.whiteColor()
        acceptBtn.backgroundColor = Theme.ColorGreen
        acceptBtn.addTarget(self, action: "acceptBtn:", forControlEvents: UIControlEvents.TouchUpInside)

        
        contentView.addSubview(mainView)
        mainView.addSubview(makeOfferLabel)
        mainView.addSubview(counterBtn)
        mainView.addSubview(acceptBtn)
        // Flexible width autoresizing causes text to jump because center text alignment doesn't animate
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func acceptBtn(sender:UIButton!)
    {
        println("Button tapped")
    }
    
}
