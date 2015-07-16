import Foundation

class Message {
    let incoming: Bool
    let text: String
    let offer: NSDictionary
    let sentDate: NSDate

    init(incoming: Bool, text: String, offer: NSDictionary, sentDate: NSDate) {
        self.incoming = incoming
        self.text = text
        self.offer = offer
        self.sentDate = sentDate
    }
}
