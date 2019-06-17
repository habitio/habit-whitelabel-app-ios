//
//  MZTutorialViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 07/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZTutorialViewModel: NSObject
{
    var infoURL: URL?
	
	var steps: [MZTutorialStepViewModel] = []
    
    
    var model : MZServiceTutorial?
    
    init(model : MZServiceTutorial)
    {
        self.model = model
        self.infoURL = URL(string: model.url)
        
        for step in model.steps {
            steps.append(MZTutorialStepViewModel(model: step))
        }
    }
    
    init(steps: [MZTutorialStepViewModel])
    {
        self.steps = steps
    }

}

class MZTutorialStepViewModel : NSObject
{
    var imageUrl: URL?
    var type: String?
    var stepTitle : String?
    var stepDescription : String?
    
    var image: UIImage?

    
    var model : MZServiceTutorialStep?
    
    init(model : MZServiceTutorialStep)
    {
        self.model = model
        self.imageUrl = URL(string: model.url)!
        self.type = model.url
        self.stepTitle = model.stepTitle
        self.stepDescription = model.stepDescription
    }
    
    init (image: UIImage, title: String,description: String)
    {
        self.image = image
        self.stepTitle = title
        self.stepDescription = description
        self.model = nil
        self.type = nil
        self.imageUrl = nil
    }
}
