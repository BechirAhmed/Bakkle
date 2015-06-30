//
//  AnalyticsView.swift
//  Bakkle
//
//  Created by Xiao, Xinyu on 6/25/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore

class AnalyticsView: UIViewController, PNChartDelegate{
    var header: UIView!
    var tabView: UIView!
    var contentView: UIView!
    var garageIndex: Int = 0
    var item: NSDictionary!
    var pieChartHeight: CGFloat = 0
    var lineChartHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.item = Bakkle.sharedInstance.garageItems[self.garageIndex] as? NSDictionary
        
        self.headerSetup()
        self.tabsSetup()
        self.contentSetup()
    }
    
    func headerSetup() {
        let topHeight: CGFloat = 20
        let headerHeight: CGFloat = 44
        header = UIView(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width, headerHeight+topHeight))
        header.backgroundColor = Theme.ColorGreen
        
        let buttonWidth: CGFloat = 96.0
        var backButton = UIButton(frame: CGRectMake(header.bounds.origin.x, header.bounds.origin.y+20, buttonWidth, headerHeight))
        backButton.setImage(UIImage(named: "icon-back.png"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "btnBack:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        header.addSubview(backButton)
        
        let editButtonWidth:CGFloat = 50
        var editButton = UIButton(frame: CGRectMake(header.bounds.origin.x+header.bounds.size.width-55
            ,header.bounds.origin.y + 25,editButtonWidth,headerHeight-10))
        editButton.setImage(IconImage().edit(headerHeight-10), forState: UIControlState.Normal)
        editButton.addTarget(self, action: "editItem:", forControlEvents: UIControlEvents.TouchUpInside)
        header.addSubview(editButton)
        
        var title = UILabel(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y + topHeight, view.bounds.size.width, headerHeight))
        title.center = CGPointMake((editButton.frame.origin.x - backButton.frame.size.width - backButton.frame.origin.x)/2+backButton.frame.size.width+backButton.frame.origin.x, topHeight + (headerHeight/2))
        title.textAlignment = NSTextAlignment.Center
        title.font = UIFont(name: "Avenir-Black", size: 20)
        title.textColor = UIColor.whiteColor()
//        title.text = (item.valueForKey("title") as? String)?.uppercaseString
        title.text = "ANALYTICS"
        header.addSubview(title)
        view.addSubview(header)
        
        
    }
    
    func tabsSetup() {
        let topHeight: CGFloat = 20
        let headerHeight: CGFloat = 44
        tabView = UIView(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y+headerHeight+topHeight, view.bounds.size.width, headerHeight))
        tabView.backgroundColor = UIColor.whiteColor()
        
        let edge: CGFloat = 10
        var msgButton: UIButton = UIButton(frame: CGRectMake(edge, 5, (view.bounds.size.width-20)/2, headerHeight-15))
        msgButton.setTitle("MESSAGES", forState: UIControlState.Normal)
        msgButton.titleLabel!.font = UIFont(name: "Avenir-Black", size: 15)
        msgButton.setTitleColor(Theme.ColorGreen, forState: UIControlState.Normal)
        msgButton.layer.borderWidth = 2.0
        msgButton.layer.borderColor = Theme.ColorGreen.CGColor
        msgButton.backgroundColor = UIColor.whiteColor()
        msgButton.addTarget(self, action: "msgPressed", forControlEvents: UIControlEvents.TouchUpInside)
        tabView.addSubview(msgButton)
        
        var alyButton: UIButton = UIButton(frame: CGRectMake(edge+msgButton.frame.size.width, 5, (view.bounds.size.width-20)/2, headerHeight-15))
        alyButton.setTitle("ANALYTICS", forState: UIControlState.Normal)
        alyButton.titleLabel!.font = UIFont(name: "Avenir-Black", size: 15)
        
        alyButton.layer.borderWidth = 2.0
        alyButton.layer.borderColor = Theme.ColorGreen.CGColor
        alyButton.backgroundColor = Theme.ColorGreen
        alyButton.addTarget(self, action: "alyPressed", forControlEvents: UIControlEvents.TouchUpInside)
        tabView.addSubview(alyButton)
        view.addSubview(tabView)
    }
    
    func contentSetup() {
        contentView = UIView(frame: CGRectMake(view.bounds.origin.x,view.bounds.origin.y+header.frame.size.height+tabView.frame.size.height,view.bounds.size.width,view.bounds.size.height-header.frame.size.height-tabView.frame.size.height))
        contentView.backgroundColor = UIColor.whiteColor()
        view.addSubview(contentView)
        
        pieChartHeight = contentView.frame.height / 7 * 4
        lineChartHeight = contentView.frame.height / 7 * 3
        
        var userLabel: UILabel = UILabel(frame: CGRectMake(view.bounds.origin.x, 5, view.bounds.size.width, 20))
        userLabel.textAlignment = NSTextAlignment.Center
        userLabel.text = "user interaction".uppercaseString
        userLabel.textColor = Theme.ColorGreen
        userLabel.font = UIFont(name: "Avenir-Black", size: 20)
        contentView.addSubview(userLabel)
        
        self.pieChartSetup()
        
        var viewLabel: UILabel = UILabel(frame: CGRectMake(view.bounds.origin.x, 20+pieChartHeight, view.bounds.size.width, 20))
        viewLabel.textAlignment = NSTextAlignment.Center
        viewLabel.text = "Views Per Day".uppercaseString
        viewLabel.textColor = Theme.ColorGreen
        viewLabel.font = UIFont(name: "Avenir-Black", size: 20)
        contentView.addSubview(viewLabel)
        
        self.lineChartSetup()
        
    }
    
    func pieChartSetup() {
        
        let holdNum = item.valueForKey("number_of_holding") as? CGFloat
        let wantNum = item.valueForKey("number_of_want") as? CGFloat
        let nopeNum = item.valueForKey("number_of_meh") as? CGFloat
        let reportNum = item.valueForKey("number_of_report") as? CGFloat
        
        var items: NSMutableArray = NSMutableArray()
        if holdNum != 0 {
            items.addObject(PNPieChartDataItem(value: holdNum!, color: Theme.ColorBlue, description: "HOLD"))
        }
        if wantNum != 0 {
            items.addObject(PNPieChartDataItem(value: wantNum!, color: Theme.ColorGreen, description: "WANT"))
        }
        if nopeNum != 0 {
            items.addObject(PNPieChartDataItem(value: nopeNum!, color: Theme.ColorRed, description: "NOPE"))
        }
        if reportNum != 0 {
            items.addObject(PNPieChartDataItem(value: reportNum!, color: Theme.ColorOrange, description: "REPORT"))
        }
        if items.count == 0 {
            items.addObject(PNPieChartDataItem(value: 0, color: Theme.ColorGreen, description: "NO VIEWS"))
        }
        var itemArray = items as AnyObject as! [PNPieChartDataItem]
        var pieChart: PNPieChart = PNPieChart(frame: CGRectMake((view.bounds.size.width - (pieChartHeight - 35))/2, 35, pieChartHeight - 35, pieChartHeight - 35), items: itemArray)
        pieChart.descriptionTextColor = UIColor.whiteColor()
        pieChart.descriptionTextFont = UIFont(name: "Avenir-Heavy", size: 17)
        pieChart.strokeChart()
        contentView.addSubview(pieChart)
        
        var viewsLabel: UILabel = UILabel(frame: CGRectMake(view.bounds.origin.x, 27+(pieChartHeight - 35)/2, view.bounds.size.width, 20))
        viewsLabel.textAlignment = NSTextAlignment.Center
        viewsLabel.text = "VIEWS"
        viewsLabel.textColor = Theme.ColorGreen
        viewsLabel.font = UIFont(name: "Avenir-Heavy", size: 18)
        contentView.addSubview(viewsLabel)
        
        let viewNum = item.valueForKey("number_of_views") as? NSNumber
        var numLabel: UILabel = UILabel(frame: CGRectMake(view.bounds.origin.x, 44+(pieChartHeight - 35)/2, view.bounds.size.width, 20))
        numLabel.textAlignment = NSTextAlignment.Center
        numLabel.text = viewNum?.stringValue
        numLabel.textColor = Theme.ColorGreen
        numLabel.font = UIFont(name: "Avenir-Heavy", size: 18)
        contentView.addSubview(numLabel)
    }
    
    func lineChartSetup() {
        
        var lineChart:PNLineChart = PNLineChart(frame: CGRectMake(view.bounds.origin.x, 50+pieChartHeight, view.bounds.size.width, lineChartHeight-50))
        lineChart.yLabelFormat = "%1.1f"
        lineChart.showLabel = true
        lineChart.backgroundColor = UIColor.clearColor()
        lineChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
        lineChart.showCoordinateAxis = true
        lineChart.delegate = self
        
        var data01Array: [CGFloat] = [60.1, 160.1, 126.4, 262.3, 186.2, 127.2, 176.2]
        var data01:PNLineChartData = PNLineChartData()
        data01.color = Theme.ColorGreen
        data01.itemCount = data01Array.count
        //data01.inflexionPointStyle = PNLineChartData
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            var yValue:CGFloat = data01Array[index]
            var item = PNLineChartDataItem()
            item.y = yValue
            return item
        })
        
        lineChart.chartData = [data01]
        lineChart.strokeChart()
        contentView.addSubview(lineChart)
    }

    
    func btnBack(sender:UIButton!)
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func editItem(sender:UIButton!)
    {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: AddItem = sb.instantiateViewControllerWithIdentifier("AddItem") as! AddItem
        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        vc.isEditting = true
        vc.item = self.item as NSDictionary
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func msgPressed(){
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func alyPressed(){
       // do nothing
    }

}