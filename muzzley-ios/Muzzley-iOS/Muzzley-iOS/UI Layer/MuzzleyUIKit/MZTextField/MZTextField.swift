//
//  MZTextField.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 06/12/16.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZTextField: UITextField, UITextFieldDelegate
{
	var border : CALayer?
	
	var focusedBorder : CALayer?
	var unfocusedBorder : CALayer?
	
	var editButton = UIButton()
	var clearButton = UIButton()
	
	let borderWidth : CGFloat = 1.0
	
	var isInEditMode = false
	
	required init(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)!
		delegate = self

		setupInterface()
		setUnfocusedLayout()
	}
	
	required override init(frame: CGRect)
	{
		super.init(frame: frame)
		delegate = self
		
		setupInterface()
		setUnfocusedLayout()
	}

	func setupInterface()
	{
		createButtons()
		createBorders()
		setTextStyle()
	}
	func setTextStyle()
	{
		self.textColor = UIColor.muzzleyGray2Color(withAlpha: 1.0)
//		self.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 17)
	}
	func createBorders()
	{
		self.borderStyle = UITextBorderStyle.none
		
		self.focusedBorder = CALayer()
		self.focusedBorder!.borderColor = UIColor.muzzleyBlueColor(withAlpha: 1.0).cgColor
		self.focusedBorder!.frame = CGRect(x: 0, y: self.frame.size.height - self.borderWidth, width:  UIScreen.main.bounds.width, height: self.borderWidth)
		self.focusedBorder!.borderWidth = self.borderWidth

		self.unfocusedBorder = CALayer()
		self.unfocusedBorder!.borderColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
		self.unfocusedBorder!.frame = CGRect(x: 0, y: self.frame.size.height - self.borderWidth, width:  UIScreen.main.bounds.width, height: self.borderWidth)
		self.unfocusedBorder!.borderWidth = self.borderWidth
	}
	
	func createButtons()
	{
		self.clearButtonMode = UITextFieldViewMode.never
		self.rightViewMode = UITextFieldViewMode.always
		
		editButton.setImage(UIImage(named: "icon_edit_text"), for: UIControlState())
		editButton.isUserInteractionEnabled = false
		editButton.tintColor = UIColor.muzzleyGrayColor(withAlpha: 1)
		editButton.frame = CGRect(x: 0,y: 0,width: 15,height: 15)
		
		clearButton.addTarget(self, action: #selector(self.clearTextField(_:)), for: UIControlEvents.touchUpInside)
		clearButton.setImage(UIImage(named: "icon_delete_text"), for: UIControlState())
		clearButton.isUserInteractionEnabled = true
		clearButton.tintColor = UIColor.muzzleyGrayColor(withAlpha: 1)
		clearButton.frame = CGRect(x: 0,y: 0,width: 15,height: 15)
	}
	
	
	func setFocusedBorder()
	{
		if(unfocusedBorder != nil)
		{
			self.unfocusedBorder!.removeFromSuperlayer()
		}

		self.layer.addSublayer(self.focusedBorder!)
		self.layer.masksToBounds = true
	}
	
	func setUnfocusedBorder()
	{
		self.borderStyle = UITextBorderStyle.none
		
		if(self.focusedBorder != nil)
		{
			self.focusedBorder!.removeFromSuperlayer()
		}

		self.layer.addSublayer(self.unfocusedBorder!)
		self.layer.masksToBounds = true
	}

	
	func setFocusedLayout()
	{
		setFocusedBorder()
		setClearTextButton()
	}
	
	func setUnfocusedLayout()
	{
		setUnfocusedBorder()
		setEditButton()
	}
	

	func setClearTextButton()
	{
		self.rightView = clearButton
	}
	
	
	func setEditButton()
	{
		self.rightView = editButton
	}
	
	func clearTextField(_ sender: UIButton)
	{
		if(self.isInEditMode)
		{
			self.text = ""
			setClearTextButton()
		}
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField)
	{
		isInEditMode = true
		self.setFocusedLayout()
	}
	
	func textFieldDidEndEditing(_ textField: UITextField)
	{
		isInEditMode = false
		self.setUnfocusedLayout()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		self.resignFirstResponder()
		return true
	}
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		// This needs to be here so the height is a little bigger and the line shows
		var frameRect = self.frame;
		frameRect.size.height = 32;
		self.frame = frameRect;
		
	}
}
