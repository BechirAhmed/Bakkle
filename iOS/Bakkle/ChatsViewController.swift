import UIKit

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate  {
    let joe = User(ID: 69, username: "lilswaqq", firstName: "Joseph", lastName: "Carroll")
    var account: Account!
    var chats: [Chat] = []
    var header: UIView!
    var tableView: UITableView!
    var toolBar: UIToolbar!
    var textView: UITextView!
    var profileButton: UIButton!
    var sendButton: UIButton!
    
    override var inputAccessoryView: UIView! {
        get {
            if toolBar == nil {
                toolBar = UIToolbar(frame: CGRectMake(0, 0, 0, toolBarMinHeight-0.5))
//                
//                textView = InputTextView(frame: CGRectZero)
//                textView.backgroundColor = UIColor.whiteColor()
//                textView.delegate = self
//                textView.font = UIFont.systemFontOfSize(messageFontSize)
//                textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
//                textView.layer.borderWidth = 0.5
//                textView.layer.cornerRadius = 5
//                //        textView.placeholder = "Message"
//                textView.scrollsToTop = false
//                textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
//                
//                sendButton = UIButton.buttonWithType(.System) as! UIButton
//                sendButton.enabled = false
//                sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
//                sendButton.setTitle("Send", forState: .Normal)
//                sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), forState: .Disabled)
//                sendButton.setTitleColor(UIColor(red: 1/255, green: 122/255, blue: 255/255, alpha: 1), forState: .Normal)
//                sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
//                sendButton.addTarget(self, action: "sendAction", forControlEvents: UIControlEvents.TouchUpInside)
//                toolBar.addSubview(sendButton)
//                
//                // Auto Layout allows `sendButton` to change width, e.g., for localization.
//                textView.setTranslatesAutoresizingMaskIntoConstraints(false)
//                sendButton.setTranslatesAutoresizingMaskIntoConstraints(false)
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: toolBar, attribute: .Left, multiplier: 1, constant: 8))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: toolBar, attribute: .Top, multiplier: 1, constant: 7.5))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: sendButton, attribute: .Left, multiplier: 1, constant: -2))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -8))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Right, relatedBy: .Equal, toItem: toolBar, attribute: .Right, multiplier: 1, constant: 0))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -4.5))
            }
            return toolBar
        }
    }

    
    
//    convenience init() {
//        self.init(style: .Plain)
//        title = "Chats"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "composeAction")
//    }
    
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

        let joe = User(ID: 69, username: "lilswaqq", firstName: "Joseph", lastName: "Carroll")
        self.account = Account(user: joe)
        
        let minute: NSTimeInterval = 60, hour = minute * 60, day = hour * 24
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
        navigationItem.leftBarButtonItem = editButtonItem() // TODO: KVO
        self.tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.rowHeight = chatCellHeight
        self.tableView.separatorInset.left = chatCellInsetLeft
        self.tableView.registerClass(ChatCell.self, forCellReuseIdentifier: NSStringFromClass(ChatCell))
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
        navigationController?.pushViewController(chatViewController, animated: true)
    }

    func composeAction() {
        let navigationController = UINavigationController(rootViewController: ComposeViewController())
        presentViewController(navigationController, animated: true, completion: nil)
    }
}
