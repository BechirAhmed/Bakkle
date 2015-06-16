import UIKit

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate  {
    let testUser = User(ID: 99, username: "testuser", firstName: "Test", lastName: "User")
    var account: Account!
    var chats: [Chat] = []
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

        let testUser = User(ID: 99, username: "testuser", firstName: "Test", lastName: "User")
        self.account = Account(user: testUser)
        let minute: NSTimeInterval = 60, hour = minute * 60, day = hour * 24
        //WSManager.enqueueWorkPayload(payload: WSStartChatRequest(itemId: chatItemID))
        account.chats = [
            Chat(user: User(ID: 2, username: "samihah", firstName: "Angel", lastName: "Rao"), lastMessageText: "6 sounds good :-)", lastMessageSentDate: NSDate()),
            Chat(user: User(ID: 3, username: "walterstephanie", firstName: "Valentine", lastName: "Sanchez"), lastMessageText: "Haha", lastMessageSentDate: NSDate(timeIntervalSinceNow: -minute)),
            Chat(user: User(ID: 23, username: "benlu", firstName: "Ben", lastName: "Lu"), lastMessageText: "I have no profile picture.", lastMessageSentDate: NSDate()),
            Chat(user: User(ID: 4, username: "wake_gs", firstName: "Aghbalu", lastName: "Amghar"), lastMessageText: "Damn", lastMessageSentDate: NSDate(timeIntervalSinceNow: -hour*13)),
            Chat(user: User(ID: 22, username: "liveloveprosper", firstName: "中文 日本語", lastName: "한국인"), lastMessageText: "I have no profile picture or extended ASCII initials.", lastMessageSentDate: NSDate()),
            Chat(user: User(ID: 5, username: "kfriedson", firstName: "Candice", lastName: "Meunier"), lastMessageText: "I can't wait to see you! ❤️", lastMessageSentDate: NSDate(timeIntervalSinceNow: -hour*34)),
            Chat(user: User(ID: 6, username: "mmorits", firstName: "Ferdynand", lastName: "Kaźmierczak"), lastMessageText: "http://youtu.be/UZb2NOHPA2A", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*2-1)),
            Chat(user: User(ID: 7, username: "krystalfister", firstName: "Lauren", lastName: "Cooper"), lastMessageText: "Thinking of you...", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*3)),
            Chat(user: User(ID: 8, username: "christianramsey", firstName: "Bradley", lastName: "Simpson"), lastMessageText: "👍", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*4)),
            Chat(user: User(ID: 9, username: "curiousonaut", firstName: "Clotilde", lastName: "Thomas"), lastMessageText: "Sounds good!", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*5)),
            Chat(user: User(ID: 10, username: "acoops_", firstName: "Tania", lastName: "Caramitru"), lastMessageText: "Cool. Thanks!", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*6)),
            Chat(user: User(ID: 11, username: "tpatteri", firstName: "Ileana", lastName: "Mazilu"), lastMessageText: "Hey, what are you up to?", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*7)),
            Chat(user: User(ID: 12, username: "giuliusa", firstName: "Asja", lastName: "Zuhrić"), lastMessageText: "Drinks tonight?", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*8)),
            Chat(user: User(ID: 13, username: "liang", firstName: "Sarah", lastName: "Lam"), lastMessageText: "Are you going to Blues on the Green tonight?", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*9)),
            Chat(user: User(ID: 14, username: "dhoot_amit", firstName: "Ishan", lastName: "Sarin"), lastMessageText: "Thanks for open sourcing Chats.", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*10)),
            Chat(user: User(ID: 15, username: "leezlee", firstName: "Stella", lastName: "Vosper"), lastMessageText: "Those who dance are considered insane by those who can't hear the music.", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*11)),
            Chat(user: User(ID: 16, username: "elenadissi", firstName: "Georgeta", lastName: "Mihăileanu"), lastMessageText: "Hey, what are you up to?", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*11)),
            Chat(user: User(ID: 17, username: "juanadearte", firstName: "Alice", lastName: "Adams"), lastMessageText: "Hey, want to hang out tonight?", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*11)),
            Chat(user: User(ID: 18, username: "teleject", firstName: "Gerard", lastName: "Gómez"), lastMessageText: "Haha. Hell yeah! No problem, bro!", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*11)),
            Chat(user: User(ID: 19, username: "oksanafrewer", firstName: "Melinda", lastName: "Osváth"), lastMessageText: "I am excellent!!! I was thinking recently that you are a very inspirational person.", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*11)),
            Chat(user: User(ID: 20, username: "cynthiasavard", firstName: "Saanvi", lastName: "Sarin"), lastMessageText: "See you soon!", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*11)),
            Chat(user: User(ID: 21, username: "stushona", firstName: "Jade", lastName: "Roger"), lastMessageText: "😊", lastMessageSentDate: NSDate(timeIntervalSinceNow: -day*11))
        ]
        self.chats = self.account!.chats
        
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
        return chats.count
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
        let chat = chats[indexPath.row]
        let chatViewController = ChatViewController(chat: chat)
        chatViewController.index = indexPath.row
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
