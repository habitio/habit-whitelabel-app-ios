//
//  MZTextView.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 16/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZTextView : UITextView {
    
}

extension UITextView {
    public var safeText:NSAttributedString!
        {
        set {
            let selectable = self.selectable;
            self.selectable = true;
            self.attributedText = newValue;
            self.selectable = selectable;
        }
        get {
            return self.attributedText;
        }
    }
}