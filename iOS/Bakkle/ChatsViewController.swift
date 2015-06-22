import UIKit

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate  {
    var account: Account!
    var header: UIView!
    var tableView: UITableView!
    var textView: UITextView!
    var chatItemID: String!
    
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
        
        var title = UILabel(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y + topHeight, view.bounds.size.width, headerHeight))
        title.center = CGPointMake((view.bounds.size.width/2), topHeight + (headerHeight/2))
        title.textAlignment = NSTextAlignment.Center
        title.text = "CHATS"
        title.font = UIFont(name: "Avenir-Black", size: 21)
        title.textColor = UIColor.whiteColor()
        
        header.addSubview(title)
        view.addSubview(header)
        
        tableView = UITableView(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y+headerHeight+topHeight, view.bounds.size.width, view.bounds.size.height-headerHeight-topHeight), style: .Plain)
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
                var id: Int = 0
                
                if let lastMessage = chat.valueForKey("last_message") as? NSDictionary {
                    message = lastMessage.valueForKey("message") as! String
                    dateString = lastMessage.valueForKey("date") as! String
                    date = NSDate().dateFromString(dateString, format:  "yyyy-MM-dd HH:mm:ss")
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
                self.tableView.reloadData()
            }
        }
        WSManager.enqueueWorkPayload(chatPayload)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
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
        chatViewController.index = indexPath.row
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
