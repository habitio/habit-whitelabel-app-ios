//
//  ArrayExtensions.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 19/02/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
