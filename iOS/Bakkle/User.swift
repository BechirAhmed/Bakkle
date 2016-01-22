import Foundation

class User {
    var facebookID: String
    var accountID: Int
    var firstName: String?
    var lastName: String?
    
    var name: String? {
        if firstName != nil && lastName != nil {
            return firstName! + " " + lastName!
        } else if firstName != nil {
            return firstName
        } else {
            return lastName
        }
    }
    var initials: String? {
        var initials: String?
        for name in [firstName, lastName] {
            if let definiteName = name {
                let initial = definiteName.substringToIndex(definiteName.startIndex.advancedBy(1))
                if initial.lengthOfBytesUsingEncoding(NSNEXTSTEPStringEncoding) > 0 {
                    initials = (initials == nil ? initial : initials! + initial)
                }
            }
        }
        return initials
    }

    init(facebookID: String, accountID: Int, firstName: String?, lastName: String?) {
        self.facebookID = facebookID
        self.accountID = accountID
        self.firstName = firstName
        self.lastName = lastName
    }
}
