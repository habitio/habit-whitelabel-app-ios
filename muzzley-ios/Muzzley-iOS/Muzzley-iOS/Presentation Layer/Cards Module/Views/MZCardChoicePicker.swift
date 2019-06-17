//
//  MZCardChoicePicker.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 10/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//


class MZCardChoicePicker: UIViewController
{
    
    var choiceButtons: [UIButton] = []
    
    let spacing : CGFloat = 25;

    var value : NSObject?
    var card: MZCardViewModel?
    var field: MZFieldViewModel?
    
    @IBOutlet weak var uiButtonsStackView: UIStackView!
    
    func setViewModel(_ cardViewModel: MZCardViewModel, fieldViewModel: MZFieldViewModel)
    {
        self.card = cardViewModel
        self.field = fieldViewModel
    }
    
    
    func setupUI()
    {
        if let previousValue : [MZChoicePlaceholderViewModel] = self.field!.getValue() as? [MZChoicePlaceholderViewModel]
        {
            self.value = previousValue as NSObject
        } else {
            self.value = field!.placeholders as? [MZChoicePlaceholderViewModel] as! NSObject
        }
        self.field?.setValue(self.value!)
        
        setOptionButtons()
    }
    

    
    func setOptionButtons()
    {
        for subview in self.uiButtonsStackView.arrangedSubviews
        {
            self.uiButtonsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        if let choices : [MZChoicePlaceholderViewModel] = self.value as? [MZChoicePlaceholderViewModel]
        {
            for choice in choices
            {
                self.uiButtonsStackView.addArrangedSubview(createButton(choiceVM: choice))
            }
        }
        
    }
    
    func setButtonState(_ button : UIButton, state: Bool)
    {
        button.isSelected = state
        if state
        {
            button.layer.borderColor = UIColor.muzzleyBlueColor(withAlpha: 1.0).cgColor
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        } else
        {
            button.layer.borderColor = UIColor.muzzleyBlueColor(withAlpha: 0.3).cgColor
            button.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        }
    }
    
    func createButton(choiceVM : MZChoicePlaceholderViewModel) -> UIButton
    {
        let height : CGFloat        = 40
        let margin : CGFloat        = 10
        
        var choiceButton = UIButton(type: .custom)
        choiceButton.setTitle(choiceVM.label.uppercased(), for: .normal)        
        choiceButton.frame = CGRect(x: 0, y: 0, width: self.uiButtonsStackView!.frame.size.width, height: height)
        choiceButton.setTitleColor(UIColor.muzzleyBlackColor(withAlpha: 0.3), for: .normal)
        choiceButton.setTitleColor(UIColor.muzzleyBlackColor(withAlpha: 1.0), for: .selected)
        choiceButton.titleLabel?.font = UIFont.semiboldFontOfSize(12)
        choiceButton.contentHorizontalAlignment = .left;
        choiceButton.addTarget(self, action: #selector(MZCardChoicePicker.didTapChoice(_:)), for: UIControlEvents.touchUpInside)
        choiceButton.layer.borderWidth = 1.0
        choiceButton.layer.cornerRadius = choiceButton.frame.size.height / 2.0
        choiceButton.layer.masksToBounds = true
        let bbiImage = UIImage(named: "IconCheck")
        choiceButton.setImage(bbiImage, for: .selected)
        choiceButton.imageEdgeInsets = UIEdgeInsetsMake(0, choiceButton.frame.size.width - bbiImage!.size.width - spacing, 0, 0);
        choiceButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        setButtonState(choiceButton, state: choiceVM.selected)
        
        return choiceButton
    }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    
    func didTapChoice (_ tappedButton: UIButton)
    {
        setButtonState(tappedButton, state: !tappedButton.isSelected)
        
        if let choices : [MZChoicePlaceholderViewModel] = self.value as? [MZChoicePlaceholderViewModel]
        {
            let i = uiButtonsStackView.arrangedSubviews.firstIndex(of: tappedButton)
            var choice = choices[i!]
            choice.selected = tappedButton.isSelected
            
            if !choice.multiSelection
            {
                for button in self.uiButtonsStackView.arrangedSubviews
                {
                    if tappedButton != button
                    {
                        // Disable all the other buttons
                        setButtonState(button as! UIButton, state: false)
                        let j = uiButtonsStackView.arrangedSubviews.firstIndex(of: button)
                        choice = choices[j!]
                        choice.selected = false
                    }
                }
            }
        }
        
        self.field!.setValue(self.value!)
    }

}
