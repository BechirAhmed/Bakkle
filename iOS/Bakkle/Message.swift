import Foundation

class Message {
    let incoming: Bool
    let text: String
    let offer: String
    let sentDate: NSDate

    init(incoming: Bool, text: String, offer: String, sentDate: NSDate) {
        self.incoming = incoming
        self.text = text
        self.offer = offer
        self.sentDate = sentDate
    }
}
