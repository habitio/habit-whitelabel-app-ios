//
//  MZUnlinkAccountsViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 12/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZUnlinkAccountsViewController : BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var wireframe: UserProfileWireframe!
    private var accountsToUnlink: NSArray!

    convenience init(withWireframe wireframe: UserProfileWireframe) {
        self.init(nibName: "MZUnlinkAccountsViewController", bundle: NSBundle.mainBundle())
        
        self.wireframe = wireframe
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
    }
    
    private func setupInterface() {
        self.title = NSLocalizedString("mobile_title_unlink_accounts", comment: "")
        self.tableView.tableFooterView = UIView()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - UITableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel!.text = "Account Type"
        cell.textLabel!.font = UIFont.lightFontOfSize(15)
        
        return cell
    }
}
