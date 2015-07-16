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
    var messageType: UISegmentedControl!
    var profileButton: UIButton!
    var sendButton: UIButton!
    var rotating = false
    var chatID: String!
    var itemIndex: Int = 0
    var seller: NSDictionary!
    var isBuyer: Bool = false
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var offerTF: UITextField!
    var offerSent: Bool = false
    var offerReceived: Bool = false
    
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
                // maybe placeholder text?
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
        
        
        let buttonWidth: CGFloat = 80.0
        var backButton = UIButton(frame: CGRectMake(header.bounds.origin.x + 4, header.bounds.origin.y+24, buttonWidth, headerHeight - 8))
        backButton.setImage(UIImage(named: "icon-back.png"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "btnBack:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        header.addSubview(backButton)
        
        let profileButtonWidth: CGFloat = 36
        let profileXpos:CGFloat = (header.bounds.size.width - header.bounds.origin.x
            - profileButtonWidth) / 2
        profileButton = UIButton(frame: CGRectMake(profileXpos, header.bounds.origin.y+topHeight+4, profileButtonWidth, headerHeight-4))
        profileButton.backgroundColor = Theme.ColorGreen
        profileButton.setImage(UIImage(named: "loading.png"), forState: UIControlState.Normal)
        profileButton.imageView?.layer.cornerRadius = profileButton.imageView!.frame.size.width/2
        profileButton.imageView?.layer.borderWidth = 1.5
        profileButton.imageView?.layer.borderColor = UIColor.whiteColor().CGColor
        profileButton.addTarget(self, action: "btnProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        header.addSubview(profileButton)
        
        let infoButtonWidth:CGFloat = 50
        var infoButton = UIButton(frame: CGRectMake(header.bounds.origin.x+header.bounds.size.width-infoButtonWidth, header.bounds.origin.y+topHeight, infoButtonWidth, headerHeight))
        infoButton.setImage(UIImage(named: "icon-i.png"), forState: UIControlState.Normal)
        infoButton.addTarget(self, action: "btnI:", forControlEvents: UIControlEvents.TouchUpInside)
        header.addSubview(infoButton)
        
        let offerButtonWidth:CGFloat = 50
        var offerButton = UIButton(frame: CGRectMake(header.bounds.origin.x+header.bounds.size.width-infoButtonWidth-offerButtonWidth, header.bounds.origin.y+topHeight, offerButtonWidth, headerHeight))
        offerButton.setImage(IconImage().check(), forState: UIControlState.Normal)
        offerButton.addTarget(self, action: "btnOffer:", forControlEvents: UIControlEvents.TouchUpInside)
        header.addSubview(offerButton)
        view.addSubview(header)
        
        tableView = UITableView(frame: CGRectMake(view.bounds.origin.x, view.bounds.origin.y+headerHeight+topHeight, view.bounds.size.width, view.bounds.size.height-headerHeight-self.inputAccessoryView.bounds.size.height), style: .Plain)
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
        refreshControl.addTarget(self, action: Selector("refreshChat"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        tableViewScrollToBottomAnimated(true) // doesn't work
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
        
        if isBuyer {
            let seller_facebookid = seller.valueForKey("facebook_id") as! String
            var facebookProfileImageUrlString = "http://graph.facebook.com/\(seller_facebookid)/picture?width=142&height=142"
            let imgURL = NSURL(string: facebookProfileImageUrlString)
            profileButton.hnk_setImageFromURL(imgURL!, state: UIControlState.Normal, placeholder: UIImage(named:"loading.png"), format: nil, failure: nil, success: nil)
        }
        else {
            let user = chat.user
            var facebookProfileImageUrlString = "http://graph.facebook.com/\(user.facebookID)/picture?width=142&height=142"
            let imgURL = NSURL(string: facebookProfileImageUrlString)
            profileButton.hnk_setImageFromURL(imgURL!, state: UIControlState.Normal, placeholder: UIImage(named:"loading.png"), format: nil, failure: nil, success: nil)
            }
        
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
        loadMessages()
        self.refreshControl.endRefreshing()
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
                // if message is null, we have an offer
                let messageText = message.valueForKey("message") as! String
                //let offerPrice = message.valueForKey("offer") as! String
                let dateString = message.valueForKey("date_sent") as! String
                let date = NSDate().dateFromString(dateString, format:  "yyyy-MM-dd HH:mm:ss")
                let incoming = message.valueForKey("sent_by_buyer") as! Bool
                var offer = NSDictionary()
                if let offerDict = message.valueForKey("offer") as? NSDictionary {
                    offer = offerDict
                }
                if !self.isBuyer {
                    loadedMessage = Message(incoming: incoming, text: messageText, offer: offer, sentDate: date)
                } else {
                    loadedMessage = Message(incoming: !incoming, text: messageText, offer: offer, sentDate: date)
                }
                loadedMessages.append(loadedMessage)
            }
            self.chat.loadedMessages = loadedMessages.reverse()
            self.tableView.reloadData()
            self.tableViewScrollToBottomAnimated(true)
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
                let incoming = (message.valueForKey("sent_by_buyer") as! Bool) == !self.isBuyer
                let loadedMessage = Message(incoming: incoming, text: messageText, offer: NSDictionary(), sentDate: date)
                let incomingChatId = (message.valueForKey("chat") as! NSNumber).integerValue
                if(incomingChatId == self.chat.chatId){
                    self.chat.loadedMessages.append(loadedMessage)
                }
                
                print("[NewMessageHandler] NewMessageHandler received new message $'\(messageText)' from userId \(messageOrigin)");
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.tableViewScrollToBottomAnimated(true)
            })
            }, forNotification: "newMessage")
        
        // Register for offers sent via websocket
        WSManager.registerMessageHandler({ (data : [NSObject : AnyObject]!) -> Void in
            var dict: NSDictionary = data as NSDictionary
            println("received an offer")
            var message: NSDictionary = NSDictionary()
            var messageOrigin: String = ""

            if(dict.objectForKey("message") != nil){
                message = dict.objectForKey("message") as! NSDictionary
        
                let dateString = message.valueForKey("date_sent") as! String
                let date = NSDate().dateFromString(dateString, format:  "yyyy-MM-dd HH:mm:ss")
                let incoming = (message.valueForKey("sent_by_buyer") as! Bool) == !self.isBuyer
                let incomingChatId = (message.valueForKey("chat") as! NSNumber).integerValue
                
                let offer = message.objectForKey("offer") as! NSDictionary
                let offerPrice = offer.valueForKey("proposed_price") as! String
                let loadedOffer = Message(incoming: incoming, text: "", offer: offer, sentDate: date)
                
                if(incomingChatId == self.chat.chatId){
                    self.chat.loadedMessages.append(loadedOffer)
                }

                print("[NewOfferHandler] NewOfferHandler received new offer '\(offerPrice)' from userId \(messageOrigin)");
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.tableViewScrollToBottomAnimated(true)
            })
            }, forNotification: "newOffer")
        
    }
    

    func btnAcceptOffer(sender: UIButton!) {
        var sendPayload: WSRequest = WSAcceptOfferRequest(offerId: String(sender.tag))
        sendPayload.failHandler = {
            (var failure: NSDictionary) in
            self.toolBar.hidden = true
            let errorMessage = failure.valueForKey("error") as! String
            let alert: UIAlertController = UIAlertController(title: "Accept Offer Failed", message: errorMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
                self.toolBar.hidden = false
            }))
            self.presentViewController(alert, animated: false, completion: nil)
        }
        WSManager.enqueueWorkPayload(sendPayload)
        loadMessages()
        println("Accepted offer")
    }
    
    func btnRetractOffer(sender: UIButton!) {
        var sendPayload: WSRequest = WSRetractOfferRequest(offerId: String(sender.tag))
        sendPayload.failHandler = {
            (var failure: NSDictionary) in
            self.toolBar.hidden = true
            let errorMessage = failure.valueForKey("error") as! String
            let alert: UIAlertController = UIAlertController(title: "Retract Offer Failed", message: errorMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
                self.toolBar.hidden = false
            }))
            self.presentViewController(alert, animated: false, completion: nil)
        }
        WSManager.enqueueWorkPayload(sendPayload)
        loadMessages()
        println("Retracted offer")
    }
    
    func btnCounterOffer(sender: UIButton!) {
        proposeOffer()
        println("Countered offer")
    }

    func btnBack(sender:UIButton!)
    {
        self.dismissKeyboard()
        self.toolBar.hidden = true
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    /* info button action - leads to item detail view */
    func btnI(sender:UIButton!)
    {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ItemDetails = sb.instantiateViewControllerWithIdentifier("ItemDetails") as! ItemDetails
        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        if isBuyer {
            vc.item = Bakkle.sharedInstance.trunkItems[self.itemIndex].valueForKey("item") as! NSDictionary
        } else {
            vc.item = Bakkle.sharedInstance.garageItems[self.itemIndex] as! NSDictionary
        }
        self.dismissKeyboard()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func btnOffer(sender:UIButton!){
        proposeOffer()
    }
    
    func proposeOffer() {
        self.dismissKeyboard()
        self.view.endEditing(true)
        self.toolBar.hidden = true
        let alert: UIAlertController = UIAlertController(title: "Offer Proposal", message: "Enter a dollar amount to propose an offer.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({(txtField: UITextField!) in
            txtField.placeholder = "Offer amount"
            txtField.keyboardType = UIKeyboardType.DecimalPad
            self.offerTF = txtField
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
            self.toolBar.hidden = false
        }))
        alert.addAction(UIAlertAction(title: "Propose", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            self.toolBar.hidden = false
            // need to format offer text
            let offerPriceString = self.offerTF.text
            let offerPriceFormatted = self.formatPrice(offerPriceString)
            var sendPayload: WSRequest = WSSendOfferRequest(chatId: String(self.chat.chatId), offerPrice: offerPriceFormatted, offerMethod: deliveryMethod.ship)
            WSManager.enqueueWorkPayload(sendPayload)
            AudioServicesPlaySystemSound(messageSoundOutgoing)
            println("Proposed Offer: $" + self.offerTF.text)
        }))
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    func formatPrice(offerPrice: String) -> String {
        if offerPrice.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            var str = offerPrice.stringByReplacingOccurrencesOfString("$", withString: "")
            str = str.stringByReplacingOccurrencesOfString(" ", withString: "")
            var value:Float = (str as NSString).floatValue
            // Currently capping value at 100k
            if value > 100000 {
                value = 100000
            }
            return String(format: "%.2f", value )
        } else {
            return "0"
        }
    }
    
    func btnProfile(sender:UIButton!)
    {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ProfileView = sb.instantiateViewControllerWithIdentifier("ProfileView") as! ProfileView
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        vc.canEdit = false
        if isBuyer {
            let account_id = seller.valueForKey("pk") as! Int
            Bakkle.sharedInstance.getAccount(account_id, success: {
                vc.user = Bakkle.sharedInstance.responseDict
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(vc, animated: true, completion: nil)
                })
                }, fail: {})
        }else {
            Bakkle.sharedInstance.getAccount(chat.user.accountID, success: {
                vc.user = Bakkle.sharedInstance.responseDict
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(vc, animated: true, completion: nil)
                })
                }, fail: {})
        }
        
    }
    
    func dismissKeyboard(){
        //self.textView
        self.textView.resignFirstResponder()
    }
    
    //    // #iOS7.1
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
            if toolBar.frame.height > textViewMaxHeight.landscape {
                toolBar.frame.size.height = textViewMaxHeight.landscape+8*2-0.5
            }
        } else { // portrait
            updateTextViewHeight()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.loadedMessages.count * 2 // for sent-date cell
    }
    
    func acceptButton(){
        // Code to support ratings
//        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: BuyItemView = sb.instantiateViewControllerWithIdentifier("BuyItemView") as! BuyItemView
//        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
//        self.dismissKeyboard()
//        if isBuyer {
//            vc.item = Bakkle.sharedInstance.trunkItems[self.itemIndex].valueForKey("item") as! NSDictionary
//        } else {
//            vc.item = Bakkle.sharedInstance.garageItems[self.itemIndex] as! NSDictionary
//        }
//        self.presentViewController(vc, animated: true, completion: nil)
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var indexFloor: Int = Int(floor(Double(indexPath.row) * 0.5))
        let message = chat.loadedMessages[indexFloor]
        
        // Date cells
        if (indexPath.row % 2) == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessageSentDateCell), forIndexPath: indexPath) as! MessageSentDateCell
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            cell.sentDateLabel.text = dateFormatter.stringFromDate(message.sentDate)
            return cell
        }
        else {
            // Offer cells
            if message.offer.count != 0 {
                let cellIdentifier = NSStringFromClass(AcceptOfferCell)
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! AcceptOfferCell!
                if  cell == nil {
                    cell = AcceptOfferCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
                    let status = message.offer.valueForKey("status") as! String
                    let offer = message.offer.valueForKey("proposed_price") as! String
                    if message.incoming {
                        if status == "Accepted" {
                            cell.makeOfferLabel.text = "YOU ACCEPTED THE OFFER OF $\(offer)."
                        } else if status == "Retracted" {
                            cell.makeOfferLabel.text = "YOU REJECTED THE OFFER OF $\(offer)."
                        } else {
                            cell.makeOfferLabel.text = "AN OFFER OF $\(offer) HAS BEEN MADE."
                            var acceptBtn: UIButton = UIButton()
                            var counterBtn: UIButton = UIButton()
                            acceptBtn.addTarget(self, action: "btnAcceptOffer:", forControlEvents: UIControlEvents.TouchUpInside)
                            acceptBtn.tag = message.offer.valueForKey("pk") as! Int
                            cell.contentView.addSubview(acceptBtn)
                            cell.configureAcceptBtn(acceptBtn)
                            counterBtn.addTarget(self, action: "btnCounterOffer:", forControlEvents: UIControlEvents.TouchUpInside)
                            counterBtn.tag = message.offer.valueForKey("pk") as! Int
                            cell.contentView.addSubview(counterBtn)
                            cell.configureCounterBtn(counterBtn)
                        }
                    } else {
                        if status == "Accepted" {
                            cell.makeOfferLabel.text = "YOUR OFFER OF $\(offer) WAS ACCEPTED."
                        } else if status == "Retracted" {
                            cell.makeOfferLabel.text = "YOUR OFFER OF $\(offer) WAS REJECTED."
                        } else {
                            cell.makeOfferLabel.text = "YOU PROPOSED AN OFFER OF $\(offer)."
                            var retractBtn: UIButton = UIButton()
                            retractBtn.addTarget(self, action: "btnRetractOffer:", forControlEvents: UIControlEvents.TouchUpInside)
                            retractBtn.tag = message.offer.valueForKey("pk") as! Int
                            cell.contentView.addSubview(retractBtn)
                            cell.configureRetractBtn(retractBtn)
                        }
                    }
                }
                return cell
            }
            // Message cells
            else {
                let cellIdentifier = NSStringFromClass(MessageBubbleCell)
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MessageBubbleCell!
                if cell == nil {
                    cell = MessageBubbleCell(style: .Default, reuseIdentifier: cellIdentifier)                    // Add gesture recognizers #CopyMessage
                    let action: Selector = "messageShowMenuAction:"
                    let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
                    doubleTapGestureRecognizer.numberOfTapsRequired = 2
                    cell.bubbleImageView.addGestureRecognizer(doubleTapGestureRecognizer)
                    cell.bubbleImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: action))
                }
                cell.configureWithMessage(message)
                return cell
            }
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
        
        var sendPayload: WSRequest = WSSendChatMessageRequest(chatId: String(chat.chatId), message: textView.text)
        WSManager.enqueueWorkPayload(sendPayload)
        
        textView.text = nil
        updateTextViewHeight()
        sendButton.enabled = false
        AudioServicesPlaySystemSound(messageSoundOutgoing)
    }
    
    func tableViewScrollToBottomAnimated(animated: Bool) {
        let numberOfRows = tableView.numberOfRowsInSection(0)
        if numberOfRows > 0 {
            //tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: numberOfRows-2, inSection: 0), atScrollPosition: .Bottom, animated: animated)
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
