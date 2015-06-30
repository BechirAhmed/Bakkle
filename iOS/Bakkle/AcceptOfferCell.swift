//
//  AcceptOfferCell.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 6/29/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation

class AcceptOfferCell: UITableViewCell {
    let makeOfferLabel: UILabel = UILabel()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        
        makeOfferLabel.backgroundColor = UIColor.clearColor()
        makeOfferLabel.font = UIFont(name: "Avenir-Black", size: 14)
        makeOfferLabel.textAlignment = .Center
        makeOfferLabel.textColor = UIColor.darkGrayColor()
    
        contentView.addSubview(makeOfferLabel)
        
        makeOfferLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 15))
    }
    
    func configureAcceptBtn(acceptBtn: UIButton){
        acceptBtn.setTitle("ACCEPT", forState: UIControlState.Normal)
        acceptBtn.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        acceptBtn.tintColor = UIColor.whiteColor()
        acceptBtn.backgroundColor = Theme.ColorGreen
        acceptBtn.userInteractionEnabled = true
        
        acceptBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: acceptBtn, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -20))
        contentView.addConstraint(NSLayoutConstraint(item: acceptBtn, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .Bottom, relatedBy: .Equal, toItem: acceptBtn, attribute: .Top, multiplier: 1, constant: -5))
    }
    
    func configureCounterBtn(counterBtn: UIButton){
        counterBtn.setTitle("COUNTER", forState: UIControlState.Normal)
        counterBtn.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        counterBtn.tintColor = UIColor.whiteColor()
        counterBtn.backgroundColor = UIColor.redColor()
        
        counterBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: counterBtn, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: counterBtn, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: -10))
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .Bottom, relatedBy: .Equal, toItem: counterBtn, attribute: .Top, multiplier: 1, constant: -5))
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
