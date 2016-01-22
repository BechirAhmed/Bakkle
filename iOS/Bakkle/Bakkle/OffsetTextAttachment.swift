//
//  OffsetTextAttachment.swift
//  Bakkle
//
//  Created by Carroll, Joseph B on 6/9/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation

class OffsetTextAttachment: NSTextAttachment {
    
    var fontDescender: CGFloat = 0.0
    
    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        var bounds: CGRect = super.attachmentBoundsForTextContainer(textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
        bounds.origin.y = self.fontDescender / 2
        return bounds
    }
}