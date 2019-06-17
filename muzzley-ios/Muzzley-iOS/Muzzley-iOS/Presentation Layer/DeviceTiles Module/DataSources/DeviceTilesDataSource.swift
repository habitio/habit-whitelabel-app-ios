	//
//  DeviceTilesDataSource.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//


@objc protocol DeviceTilesDataSourceDelegate {
    @objc optional func deviceTilesDataSource(_ toggle: MZTriStateToggle, dataSource: DeviceTilesDataSource, didSelectSwitchTileState: MZAreaChildViewModel)
}

class DeviceTilesDataSource: MZCollectionViewDataSource, DeviceTileCellDelegate
{
	var firstGroupViewIndexPath: NSIndexPath?
	var foundFirstGroupInList = false
	
	var canCreateGroups = false
	
    var delegate: DeviceTilesDataSourceDelegate? 
    var deviceAreaViewModelList : Array<MZTileAreaViewModel> = Array()
    var isDetail: Bool = false
    
    override init(collectionView: MZCollectionView) {
        super.init(collectionView: collectionView)
		self.foundFirstGroupInList = false
		self.firstGroupViewIndexPath = nil
        // Register cells
        self.collectionView?.register(DeviceTileCell.self, forCellWithReuseIdentifier: NSStringFromClass(DeviceTileCell.self))
        self.collectionView?.register(DeviceGroupTileCell.self, forCellWithReuseIdentifier: NSStringFromClass(DeviceGroupTileCell.self))
        self.collectionView?.register(GroupInteractionTileCell.self, forCellWithReuseIdentifier: NSStringFromClass(GroupInteractionTileCell.self))
        self.collectionView?.register(DeviceAreaView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(DeviceAreaView.self))
        self.collectionView?.register(UINib(nibName: "MZDeviceDetailTileCell", bundle: nil), forCellWithReuseIdentifier: "MZDeviceDetailTileCell")
    }
	
	
	// TODO: Check this. not working after swift 3 conversion
    // MARK: MZCollectionViewDataSource subclass

	
	
    override func collectionView(_ collectionView: UICollectionView!, reuseIdentifierForCellAt indexPath: IndexPath!) -> String! {
        if self.deviceAreaViewModelList[indexPath.section].tilesViewModel[indexPath.item] is MZTileGroupViewModel
		{
			if(!self.foundFirstGroupInList)
			{
				self.firstGroupViewIndexPath = indexPath as! NSIndexPath
				self.foundFirstGroupInList = true
			}
			return NSStringFromClass(DeviceGroupTileCell.self)
		} else if self.deviceAreaViewModelList[indexPath.section].tilesViewModel[indexPath.item] is MZTileViewModel {
            return NSStringFromClass(!self.isDetail ? DeviceTileCell.self : MZDeviceDetailTileCell.self)
        } else {
            return NSStringFromClass(GroupInteractionTileCell.self)
        }
    }
	
    override func collectionView(_ collectionView: UICollectionView!, reuseIdentifierForSupplementaryElementOfKind kind: String!, at indexPath: IndexPath!) -> String! {
        return NSStringFromClass(DeviceAreaView.self)
    }
	
	

	
	
    override func collectionView(_ collectionView: UICollectionView!, modelForCellAt indexPath: IndexPath!) -> NSObject! {
        return self.deviceAreaViewModelList[indexPath.section].tilesViewModel[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView!, modelFor reusableView: MZCollectionReusableView!, at indexPath: IndexPath!) -> NSObject! {
        return self.deviceAreaViewModelList[indexPath.section]
    }
	
  //   MARK: MZCollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int
	{
		return self.deviceAreaViewModelList.count

	}
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if(deviceAreaViewModelList.count > 0)
		{
			return deviceAreaViewModelList[section].tilesViewModel.count
		}
		else
		{
			return 0
		}
    }
	
    override func collectionView(_ collectionView: UICollectionView!, configureCell cell: MZCollectionViewCell!, for indexPath: IndexPath!) {
        super.collectionView(collectionView, configureCell: cell, for: indexPath)
        cell.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView!, configureReusableView reusableView: MZCollectionReusableView!, for indexPath: IndexPath!) {
        super.collectionView(collectionView, configureReusableView: reusableView, for: indexPath)
    }
	
    
    func setData(_ tiles: NSArray)
    {
		checkIfCanCreateGroups(tiles)
		self.deviceAreaViewModelList = tiles as! Array<MZTileAreaViewModel>
    }
	
	func checkIfCanCreateGroups(_ tiles: NSArray)
	{
		self.canCreateGroups = false
		for area  in tiles
		{
			for tile in (area as! MZTileAreaViewModel).tilesViewModel
			{
				if(tile is MZTileGroupViewModel)
				{
					continue
				}
				if(tile.model == nil)
				{
					continue
				}
				if( !(tile.model as! MZTile).isGroupable)
				{
					continue
				}
				for t in (area as! MZTileAreaViewModel).tilesViewModel
				{
					if(tile == t)
					{
						continue
					}
					
					if(t is MZTileGroupViewModel)
					{
						continue
					}
					if(t.model == nil)
					{
						continue
					}
					
					if(!(t.model as! MZTile).isGroupable)
					{
						continue
					}
					
					if(MZBaseInteractor.isArrayContainsAnyArray((tile.model as! MZTile).componentClasses as [Any], lookFor: (t.model as! MZTile).componentClasses))
					{
						self.canCreateGroups = true
						// Only needs to find two tiles that are groupable with each other inside an area
						return
					}
				}
			}
		}
	}
	

    func deviceTileCellToggleDidChangeValue(_ cell: DeviceTileCell)
    {
        if let indexPath: IndexPath = (self.collectionView?.indexPath(for: cell))
        {
            let viewModel: MZAreaChildViewModel = self.deviceAreaViewModelList[indexPath.section].tilesViewModel[indexPath.row]
        
            self.delegate?.deviceTilesDataSource?(cell.toggle!, dataSource:self, didSelectSwitchTileState:viewModel)
        } else {
         //TODO
        }
    }
}
