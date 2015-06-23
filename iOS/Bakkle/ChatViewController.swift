import AudioToolbox
import UIKit

let messageFontSize: CGFloat = 17
let toolBarMinHeight: CGFloat = 44
let messageFont = "Avenir-Book"
let textViewMaxHeight: (portrait: CGFloat, landscape: CGFloat) = (portrait: 272, landscape: 90)
let messageSoundOutgoing: SystemSoundID = createMessageSoundOutgoing()

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    let chat: Chat
    let itemDetailSegue = "ItemDetailSegue"
    var header: UIView!
    var tableView: UITableView!
    var toolBar: UIToolbar!
    var textView: UITextView!
    var profileButton: UIButton!
    var sendButton: UIButton!
    var rotating = false
    var chatID: String!
    var index: Int = 0
    var isBuyer: Bool = false

    override var inputAccessoryView: UIView! {
    get {
        if toolBar == nil {
            toolBar = UIToolbar(frame: CGRectMake(0, 0, 0, toolBarMinHeight-0.5))

            textView = InputTextView(frame: CGRectZero)
            textView.backgroundColor = UIColor.whiteColor()
            textView.delegate = self
            textView.font = UIFont(name: messageFont, size: messageFontSize)
            textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
            textView.layer.borderWidth = 0.5
            textView.layer.cornerRadius = 5
//        textView.placeholder = "Message"
            textView.scrollsToTop = false
            textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
            toolBar.addSubview(textView)

            sendButton = UIButton.buttonWithType(.System) as! UIButton
            sendButton.enabled = false
            sendButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 17)
            sendButton.setTitle("Send", forState: .Normal)
            sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), forState: .Disabled)
            sendButton.setTitleColor(UIColor(red: 1/255, green: 122/255, blue: 255/255, alpha: 1), forState: .Normal)
            sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            sendButton.addTarget(self, action: "sendAction", forControlEvents: UIControlEvents.TouchUpInside)
            toolBar.addSubview(sendButton)

            // Auto Layout allows `sendButton` to change width, e.g., for localization.
            textView.setTranslatesAutoresizingMaskIntoConstraints(false)
            sendButton.setTranslatesAutoresizingMaskIntoConstraints(false)
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

    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        title = chat.user.name
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor() // smooths push animation

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
        
        let profileButtonWidth: CGFloat = 36
        let profileXpos:CGFloat = (header.bounds.size.width - header.bounds.origin.x
            - profileButtonWidth) / 2.0
        profileButton = UIButton(frame: CGRectMake(profileXpos, header.bounds.origin.y+topHeight+4, profileButtonWidth, headerHeight-4))
        profileButton.backgroundColor = Theme.ColorGreen
        profileButton.setImage(UIImage(named: "loading.png"), forState: UIControlState.Normal)
        profileButton.imageView?.layer.cornerRadius = profileButton.imageView!.frame.size.width/2
        

        profileButton.addTarget(self, action: "btnProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        header.addSubview(profileButton)
        
        let infoButtonWidth:CGFloat = 50
        var infoButton = UIButton(frame: CGRectMake(header.bounds.origin.x+header.bounds.size.width-infoButtonWidth, header.bounds.origin.y+topHeight, infoButtonWidth, headerHeight))
        infoButton.setImage(UIImage(named: "icon-i.png"), forState: UIControlState.Normal)
        infoButton.addTarget(self, action: "btnI:", forControlEvents: UIControlEvents.TouchUpInside)
        header.addSubview(infoButton)
        view.addSubview(header)
        
        tableView = UITableView(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y+headerHeight+topHeight, view.bounds.size.width, view.bounds.size.height-headerHeight), style: .Plain)
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.backgroundColor = UIColor.whiteColor()
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: toolBarMinHeight, right: 0)
        tableView.contentInset = edgeInsets
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .Interactive
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .None
        tableView.registerClass(MessageSentDateCell.self, forCellReuseIdentifier: NSStringFromClass(MessageSentDateCell))
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "menuControllerWillHide:", name: UIMenuControllerWillHideMenuNotification, object: nil) // #CopyMessage
        
        loadMessages()
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshChat"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        // tableViewScrollToBottomAnimated(false) // doesn't work
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
        
        var facebookProfileImageUrlString = "http://graph.facebook.com/\(Bakkle.sharedInstance.facebook_id_str)/picture?width=142&height=142"
        let imgURL = NSURL(string: facebookProfileImageUrlString)
        profileButton.hnk_setImageFromURL(imgURL!, state: UIControlState.Normal, placeholder: UIImage(named:"loading.png"), format: nil, failure: nil, success: nil)
    }

    override func viewWillDisappear(animated: Bool)  {
        super.viewWillDisappear(animated)
        chat.draft = textView.text
    }

    // This gets called a lot. Perhaps there's a better way to know when `view.window` has been set?
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()

        if !chat.draft.isEmpty {
            textView.text = chat.draft
            chat.draft = ""
            textViewDidChange(textView)
            textView.becomeFirstResponder()
        }
    }
    
    func refreshChat() {
        self.tableView.reloadData()
    }
    
    func loadMessages() {
        var loadedMessages: [Message] = []
        
        // Load messages from server
        var chatPayload: WSRequest = WSGetMessagesForChatRequest(chatId: String(chat.chatId))
        chatPayload.successHandler = {
            (var success: NSDictionary) in
            var messages: [NSDictionary] = success.valueForKey("messages") as! [NSDictionary]
            var loadedMessage: Message!
            for message in messages {
                let messageText = message.valueForKey("message") as! String
                let dateString = message.valueForKey("date_sent") as! String
                let date = NSDate().dateFromString(dateString, format:  "yyyy-MM-dd HH:mm:ss")
                let incoming = message.valueForKey("sent_by_buyer") as! Bool
                if !self.isBuyer {
                    loadedMessage = Message(incoming: incoming, text: messageText, sentDate: date)
                } else {
                    loadedMessage = Message(incoming: !incoming, text: messageText, sentDate: date)
                }
                loadedMessages.append(loadedMessage)
            }
            self.chat.loadedMessages = loadedMessages.reverse()
            self.refreshChat()
        }
        WSManager.enqueueWorkPayload(chatPayload)
        
        // Register for messages sent via websocket
        WSManager.registerMessageHandler({ (data : [NSObject : AnyObject]!) -> Void in
            var dict: NSDictionary = data as NSDictionary
            
            var message: NSDictionary = NSDictionary()
            var messageOrigin: String = ""
            
            if(dict.objectForKey("message") != nil){
                message = dict.objectForKey("message") as! NSDictionary
                
                let messageText = message.valueForKey("message") as! String
                let dateString = message.valueForKey("date_sent") as! String
                let date = NSDate().dateFromString(dateString, format:  "yyyy-MM-dd HH:mm:ss")
                let incoming = message.valueForKey("sent_by_buyer") as! Bool
                let loadedMessage = Message(incoming: incoming, text: messageText, sentDate: date)
                loadedMessages.append(loadedMessage)
                
                print("[NewMessageHandler] NewMessageHandler received new message '\(messageText)' from userId \(messageOrigin)");
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.refreshChat()
            })
        }, forNotification: "newMessage")
    }


    func btnBack(sender:UIButton!)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* info button action - leads to item detail view */
    func btnI(sender:UIButton!)
    {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ItemDetails = sb.instantiateViewControllerWithIdentifier("ItemDetails") as! ItemDetails
        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        if isBuyer {
            vc.item = Bakkle.sharedInstance.trunkItems[index].valueForKey("item") as! NSDictionary
        } else {
            vc.item = Bakkle.sharedInstance.garageItems[index] as! NSDictionary
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func btnProfile(sender:UIButton!)
    {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = sb.instantiateViewControllerWithIdentifier("ProfileView") as! UIViewController
        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController(vc, animated: true, completion: nil)
    }

//    // #iOS7.1
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//NOTE: We aren't using this, commented out to pacify warning
        //super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)

        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
            if toolBar.frame.height > textViewMaxHeight.landscape {
                toolBar.frame.size.height = textViewMaxHeight.landscape+8*2-0.5
            }
        } else { // portrait
            updateTextViewHeight()
        }
    }
    
//    // #iOS8
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.loadedMessages.count * 2 // for sent-date cell
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row % 2) == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessageSentDateCell), forIndexPath: indexPath) as! MessageSentDateCell
            var indexFloor: Int = Int(floor(Double(indexPath.row) * 0.5))
            let message = chat.loadedMessages[indexFloor]
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            cell.sentDateLabel.text = dateFormatter.stringFromDate(message.sentDate)
            return cell
        } else {
            let cellIdentifier = NSStringFromClass(MessageBubbleCell)
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MessageBubbleCell!
            if cell == nil {
                cell = MessageBubbleCell(style: .Default, reuseIdentifier: cellIdentifier)

                // Add gesture recognizers #CopyMessage
                let action: Selector = "messageShowMenuAction:"
                let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
                doubleTapGestureRecognizer.numberOfTapsRequired = 2
                cell.bubbleImageView.addGestureRecognizer(doubleTapGestureRecognizer)
                cell.bubbleImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: action))
            }
            var indexFloor: Int = Int(floor(Double(indexPath.row) * 0.5))
            let message = chat.loadedMessages[indexFloor]
            cell.configureWithMessage(message)
            return cell
        }
    }

    // Reserve row selection #CopyMessage
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }

    func textViewDidChange(textView: UITextView) {
        updateTextViewHeight()
        sendButton.enabled = textView.hasText()
    }

    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height
        let insetOld = tableView.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = tableView.contentSize.height - (tableView.frame.height-insetOld.top-insetOld.bottom)

        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.tableView.tracking || self.tableView.decelerating) {
                // Move content with keyboard
                if overflow > 0 {                   // scrollable before
                    self.tableView.contentOffset.y += insetChange
                    if self.tableView.contentOffset.y < -insetOld.top {
                        self.tableView.contentOffset.y = -insetOld.top
                    }
                } else if insetChange > -overflow { // scrollable after
                    self.tableView.contentOffset.y += insetChange + overflow
                }
            }
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16)) // http://stackoverflow.com/a/18873820/242933
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height

        // Inset `tableView` with keyboard
        let contentOffsetY = tableView.contentOffset.y
        tableView.contentInset.bottom = insetNewBottom
        tableView.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if self.tableView.tracking || self.tableView.decelerating {
            tableView.contentOffset.y = contentOffsetY
        }
    }

    func updateTextViewHeight() {
        let oldHeight = textView.frame.height
        let maxHeight = UIDevice.currentDevice().orientation==UIDeviceOrientation.Portrait ? textViewMaxHeight.portrait : textViewMaxHeight.landscape
        var newHeight = min(textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max)).height, maxHeight)
        #if arch(x86_64) || arch(arm64)
            newHeight = ceil(newHeight)
        #else
            newHeight = CGFloat(ceilf(newHeight.native))
        #endif
        if newHeight != oldHeight {
            toolBar.frame.size.height = newHeight+8*2-0.5
        }
    }

    func sendAction() {
        // Autocomplete text before sending #hack
        textView.resignFirstResponder()
        textView.becomeFirstResponder()

        chat.loadedMessages.append(Message(incoming: false, text: textView.text, sentDate: NSDate()))
        //TODO: Trap response to show if message got transmitted or not.
        //Bakkle.sharedInstance.sendChat(1, message: textView.text, success: {()->() in }, fail: {()->() in })
        
        var sendPayload: WSRequest = WSSendChatMessageRequest(chatId: String(chat.chatId), message: textView.text)
        sendPayload.successHandler = {
            (var success: NSDictionary) in
            self.refreshChat()
        }
        WSManager.enqueueWorkPayload(sendPayload)
        
        textView.text = nil
        updateTextViewHeight()
        sendButton.enabled = false

//        let lastSection = tableView.numberOfSections()
//        tableView.beginUpdates()
//        tableView.insertSections(NSIndexSet(index: lastSection), withRowAnimation: .Automatic)
//        tableView.insertRowsAtIndexPaths([
//            NSIndexPath(forRow: 0, inSection: lastSection),
//            NSIndexPath(forRow: 1, inSection: lastSection)
//            ], withRowAnimation: .Automatic)
//        tableView.endUpdates()
//        tableViewScrollToBottomAnimated(true)
        AudioServicesPlaySystemSound(messageSoundOutgoing)
    }

    func tableViewScrollToBottomAnimated(animated: Bool) {
        let numberOfRows = tableView.numberOfRowsInSection(0)
        if numberOfRows > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: numberOfRows-1, inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
    }

    // Handle actions #CopyMessage
    // 1. Select row and show "Copy" menu
    func messageShowMenuAction(gestureRecognizer: UITapGestureRecognizer) {
        let twoTaps = (gestureRecognizer.numberOfTapsRequired == 2)
        let doubleTap = (twoTaps && gestureRecognizer.state == .Ended)
        let longPress = (!twoTaps && gestureRecognizer.state == .Began)
        if doubleTap || longPress {
            let pressedIndexPath = tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(tableView))!
            tableView.selectRowAtIndexPath(pressedIndexPath, animated: false, scrollPosition: .None)

            let menuController = UIMenuController.sharedMenuController()
            let bubbleImageView = gestureRecognizer.view!
            menuController.setTargetRect(bubbleImageView.frame, inView: bubbleImageView.superview!)
            menuController.menuItems = [UIMenuItem(title: "Copy", action: "messageCopyTextAction:")]
            menuController.setMenuVisible(true, animated: true)
        }
    }
    // 2. Copy text to pasteboard
    func messageCopyTextAction(menuController: UIMenuController) {
        let selectedIndexPath = tableView.indexPathForSelectedRow()
        let selectedMessage = chat.loadedMessages[selectedIndexPath!.row-1]
        UIPasteboard.generalPasteboard().string = selectedMessage.text
    }
    // 3. Deselect row
    func menuControllerWillHide(notification: NSNotification) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
        (notification.object as! UIMenuController).menuItems = nil
    }
}

func createMessageSoundOutgoing() -> SystemSoundID {
    var soundID: SystemSoundID = 0
    let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "MessageOutgoing", "aiff", nil)
    AudioServicesCreateSystemSoundID(soundURL, &soundID)
    return soundID
}

// Only show "Copy" when editing `textView` #CopyMessage
class InputTextView: UITextView {
    override func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
        if (delegate as! ChatViewController).tableView.indexPathForSelectedRow() != nil {
            return action == "messageCopyTextAction:"
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    // More specific than implementing `nextResponder` to return `delegate`, which might cause side effects?
    func messageCopyTextAction(menuController: UIMenuController) {
        (delegate as! ChatViewController).messageCopyTextAction(menuController)
    }
}