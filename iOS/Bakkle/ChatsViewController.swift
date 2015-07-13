import UIKit

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate  {
    var account: Account!
    var header: UIView!
    var tabView: UIView!
    var tableView: UITableView!
    var textView: UITextView!
    var chatItemID: String!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var garageIndex: Int = 0
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Chats"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        //title.text = (Bakkle.sharedInstance.garageItems[self.garageIndex].valueForKey("title") as? String)?.uppercaseString
        title.text = "MESSAGES"
        title.adjustsFontSizeToFitWidth = true
        header.addSubview(title)
        view.addSubview(header)
        
        tabView = UIView(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y+headerHeight+topHeight, view.bounds.size.width, headerHeight))
        tabView.backgroundColor = UIColor.whiteColor()
        
        let edge: CGFloat = 10
        var msgButton: UIButton = UIButton(frame: CGRectMake(edge, 5, (view.bounds.size.width-20)/2, headerHeight-15))
        msgButton.setTitle("MESSAGES", forState: UIControlState.Normal)
        msgButton.titleLabel!.font = UIFont(name: "Avenir-Black", size: 15)
        msgButton.layer.borderWidth = 2.0
        msgButton.layer.borderColor = Theme.ColorGreen.CGColor
        msgButton.backgroundColor = Theme.ColorGreen
        msgButton.addTarget(self, action: "msgPressed", forControlEvents: UIControlEvents.TouchUpInside)
        tabView.addSubview(msgButton)
        
        var alyButton: UIButton = UIButton(frame: CGRectMake(edge+msgButton.frame.size.width, 5, (view.bounds.size.width-20)/2, headerHeight-15))
        alyButton.setTitle("ANALYTICS", forState: UIControlState.Normal)
        alyButton.titleLabel!.font = UIFont(name: "Avenir-Black", size: 15)
        alyButton.setTitleColor(Theme.ColorGreen, forState: UIControlState.Normal)
        alyButton.layer.borderWidth = 2.0
        alyButton.layer.borderColor = Theme.ColorGreen.CGColor
        alyButton.backgroundColor = UIColor.whiteColor()
        alyButton.addTarget(self, action: "alyPressed", forControlEvents: UIControlEvents.TouchUpInside)
        tabView.addSubview(alyButton)
        
        view.addSubview(tabView)

        tableView = UITableView(frame:CGRectMake(view.bounds.origin.x,view.bounds.origin.y+headerHeight*2+topHeight,view.bounds.size.width,view.bounds.size.height-headerHeight*2-topHeight))
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = chatCellHeight
        tableView.separatorInset.left = chatCellInsetLeft
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: NSStringFromClass(ChatCell))
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        loadChats()
        
        refreshControl.addTarget(self, action: Selector("refreshChats"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refreshChats() {
        loadChats()
        self.refreshControl.endRefreshing()
    }
    
    func loadChats(){
        
        let seller = User(facebookID: Bakkle.sharedInstance.facebook_id_str,
            firstName: Bakkle.sharedInstance.first_name, lastName: Bakkle.sharedInstance.last_name)
        self.account = Account(user: seller)
        
        var chatPayload: WSRequest = WSGetChatsRequest(itemId: chatItemID)
        chatPayload.successHandler = {
            (var success: NSDictionary) in
            var chats: [NSDictionary] = success.valueForKey("chats") as! [NSDictionary]
            for chat in chats {
                // Set up user
                var item: NSDictionary = chat.valueForKey("item") as! NSDictionary
                
                var message: String = ""
                var dateString: String = ""
                var date: NSDate = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                var id: Int = 0
                
                if let lastMessage = chat.valueForKey("last_message") as? NSDictionary {
                    message = lastMessage.valueForKey("message") as! String
                    dateString = lastMessage.valueForKey("date") as! String
                    date = NSDate().dateFromString(dateString, format: "yyyy-MM-dd HH:mm:ss")
                }
                id = chat.valueForKey("pk") as! Int
                
                var buyer: NSDictionary = chat.valueForKey("buyer") as! NSDictionary
                let facebookID = buyer.valueForKey("facebook_id") as! String
                
                let buyersName = buyer.valueForKey("display_name") as! String
                let dividedName = split(buyersName) {$0 == " "}
                let firstName = dividedName[0] as String
                let lastName = dividedName[1] as String
                
                let buyerUser = User(facebookID: facebookID, firstName: firstName, lastName: lastName)
                var buyerChat = Chat(user: buyerUser, lastMessageText: message, lastMessageSentDate: date, chatId: id)
                self.account.chats.append(buyerChat)
            }
            self.tableView.reloadData()
        }
        WSManager.enqueueWorkPayload(chatPayload)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.account!.chats.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ChatCell), forIndexPath: indexPath) as! ChatCell
        cell.configureWithChat(self.account!.chats[indexPath.row])
        return cell
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.account!.chats.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if self.account!.chats.count == 0 {
                navigationItem.leftBarButtonItem = nil  // TODO: KVO
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chat = self.account!.chats[indexPath.row]
        let chatViewController = ChatViewController(chat: chat)
        chatViewController.itemIndex = self.garageIndex
        chatViewController.isBuyer = false
        self.presentViewController(chatViewController, animated: true, completion: {})
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func composeAction() {
        let navigationController = UINavigationController(rootViewController: ComposeViewController())
        presentViewController(navigationController, animated: true, completion: nil)
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
        vc.item = Bakkle.sharedInstance.garageItems[self.garageIndex] as? NSDictionary
        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    func msgPressed(){
        // do nothing
    }
    
    func alyPressed(){
        let alyController: AnalyticsView = AnalyticsView()
        alyController.garageIndex = self.garageIndex
        self.navigationController?.pushViewController(alyController, animated: false)
    }
    
}
