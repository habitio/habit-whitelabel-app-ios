//
//  MZSettingsAddPhoneNumberViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 17/08/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
//import PhoneNumberKit


class MZSettingsAddPhoneNumberViewController : BaseViewController
{
//	var wireframe : UserProfileWireframe
	@IBOutlet weak var uiSearchView: UIView!
	@IBOutlet weak var uiDescription: UILabel!
	@IBOutlet weak var uiIconSearch: UIImageView!
	@IBOutlet weak var uiLbCountry: UILabel!
	@IBOutlet weak var uiLbError: UILabel!
	@IBOutlet var uiTfPhoneNumber: MZTextField!
	
	@IBOutlet weak var uiCountryResultsView: UIView!
	@IBOutlet weak var uiCountriesTable: UITableView!
	

//    let phoneNumberKit = PhoneNumberKit()
	
	var phoneNumber : String = ""
//    var countriesCodesList = [MZCountryPhoneCode]()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.title = NSLocalizedString("mobile_add_phone_title", comment: "")
		self.uiIconSearch.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
		
		self.uiSearchView.addGestureRecognizer(tap)
		
		self.uiSearchView.isUserInteractionEnabled = true
		
		
		self.uiLbError.text = NSLocalizedString("mobile_phone_number_invalid", comment: "")
		self.uiLbCountry.text = NSLocalizedString("mobile_country_code", comment: "")
		
		//		self.uiLbError.isHidden = false
		self.uiLbError.textColor =  UIColor.muzzleyRedColor(withAlpha: 1)
		self.uiLbError.font =  UIFont(name: "SanFranciscoDisplay-Regular", size: 12)
//		self.uiTfPhoneNumber.placeholder = NSLocalizedString("mobile_phone_number", comment: "")
				
	}
	convenience init(withWireframe wireframe: UserProfileWireframe, number: String)
	{
		self.init(nibName: "MZSettingsAddPhoneNumberViewController", bundle: Bundle.main)
		
		self.phoneNumber = number
		
//        countriesCodesList = [MZCountryPhoneCode]()
//
//        for country in self.phoneNumberKit.allCountries()
//        {
//            countriesCodesList.append(MZCountryPhoneCode(_countryName: country))
//        }
		
//		self.uiCountriesTable.dataSource = countriesCodesList
//		self.uiCountriesTable.reloadData()
	}
	
	func handleTap(_ sender: UITapGestureRecognizer)
	{
		print("Hello World")
		self.uiCountryResultsView.isHidden = false
	}

	
}
