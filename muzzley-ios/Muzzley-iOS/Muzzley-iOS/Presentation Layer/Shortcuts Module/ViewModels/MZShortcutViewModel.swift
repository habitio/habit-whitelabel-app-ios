//
//  MZShortcutViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 21/04/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

class MZShortcutViewModel : MZWorkerViewModel
{
    var isRunning: Bool = false
    var color: UIColor = UIColor.clear
    var origin: String = "manual"
    
    var shortcutModel : MZShortcut?

    func shortcutModel(_ model:MZShortcut)
    {
        self.shortcutModel = model
        self.color = model.color
        self.origin = model.origin
    }
}
