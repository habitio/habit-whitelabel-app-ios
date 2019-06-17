//
//  MZSettingsCardsViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 12/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZSettingsCardsViewViewController : BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var wireframe: UserProfileWireframe!
    private var cardsSettings: NSArray!

    convenience init(withWireframe wireframe: UserProfileWireframe) {
        self.init(nibName: "MZSettingsCardsViewController", bundle: NSBundle.mainBundle())
        
        self.wireframe = wireframe
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
    }
    
    private func setupInterface() {
        self.title = NSLocalizedString("mobile_title_cards", comment: "")
        self.tableView.tableFooterView = UIView()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - UITableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel!.text = NSLocalizedString("mobile_card_description", comment: "")
        cell.textLabel!.font = UIFont.lightFontOfSize(15)

        return cell
    }
}
