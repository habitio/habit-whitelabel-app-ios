//
//  MZDeviceTilesRefreshProtocol.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 29/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

@objc protocol MZDeviceTilesRefreshProtocol {
    @objc optional func refreshDeviceTiles()
    @objc optional func refreshNowDeviceTiles()
    @objc optional func hideGroup()
}
