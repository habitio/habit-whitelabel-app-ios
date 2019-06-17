//
//  MZTileViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZTileViewModel : MZAreaChildViewModel {
    
    var imageURL: URL? = nil
    var overlayUrl: URL? = nil
    var imageURLAlt: URL? = nil
    var tileInformations: [TileInfoViewModel] = [TileInfoViewModel]()
    var tileProperties: [MZPropertyViewModel] = [MZPropertyViewModel]()
    var iconViewModel: TileIconViewModel? = nil
    
    override init(model : MZAreaChild)
    {
        super.init(model: model)
        let tileModel = model as? MZTile
        self.imageURL = tileModel!.photoUrl
        self.imageURLAlt = tileModel?.photoUrlAlt
        if (tileModel!.overlayUrl != nil && !tileModel!.overlayUrl.isEmpty)
        {
            self.overlayUrl = URL(string: tileModel!.overlayUrl)
        }
        self.channelID = tileModel?.channel?.identifier
    }
}
