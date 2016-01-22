//
//  AcceptOfferCell.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 6/29/15.
//  Copyright (c) 2015 Bakkle. All rights reserved.
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
        
        makeOfferLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 15))
    }
    
    func configureAcceptBtn(acceptBtn: UIButton){
        acceptBtn.setTitle("ACCEPT", forState: UIControlState.Normal)
        acceptBtn.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        acceptBtn.tintColor = UIColor.whiteColor()
        acceptBtn.backgroundColor = Theme.ColorGreen
        acceptBtn.userInteractionEnabled = true
        
        acceptBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: acceptBtn, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -20))
        contentView.addConstraint(NSLayoutConstraint(item: acceptBtn, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .Bottom, relatedBy: .Equal, toItem: acceptBtn, attribute: .Top, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: acceptBtn, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    func configureCounterBtn(counterBtn: UIButton){
        counterBtn.setTitle("COUNTER", forState: UIControlState.Normal)
        counterBtn.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        counterBtn.tintColor = UIColor.whiteColor()
        counterBtn.backgroundColor = UIColor.redColor()
        
        counterBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: counterBtn, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: counterBtn, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: -10))
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .Bottom, relatedBy: .Equal, toItem: counterBtn, attribute: .Top, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: counterBtn, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    func configureRetractBtn(retractBtn: UIButton){
        retractBtn.setTitle("RETRACT", forState: UIControlState.Normal)
        retractBtn.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        retractBtn.tintColor = UIColor.whiteColor()
        retractBtn.backgroundColor = UIColor.redColor()
        
        retractBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: retractBtn, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: -100))
        contentView.addConstraint(NSLayoutConstraint(item: retractBtn, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 100))
        contentView.addConstraint(NSLayoutConstraint(item: makeOfferLabel, attribute: .Bottom, relatedBy: .Equal, toItem: retractBtn, attribute: .Top, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: retractBtn, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func acceptBtn(sender:UIButton!)
    {
        print("Button tapped")
    }
    
}
