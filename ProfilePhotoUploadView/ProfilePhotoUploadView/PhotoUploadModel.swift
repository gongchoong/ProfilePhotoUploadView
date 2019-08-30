//
//  PhotoUploadModel.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/29/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import Foundation
import UIKit

class PhotoUploadModel: NSObject {
    
    var collectionView: UICollectionView?
    let itemCount = 6
    
    init(_ cv: UICollectionView) {
        collectionView = cv
    }
}

extension PhotoUploadModel: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        cell.applyDottedBorder()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = Int(collectionView.frame.size.width)
        let collectionViewHeight = Int(collectionView.frame.size.height) - 40
        let numberOfItemsPerRow = 3
        let spacingBetweenCells = 10
        let totalSpacing = (2 * spacingBetweenCells) + ((numberOfItemsPerRow - 1) * spacingBetweenCells)
        let CellWidth = Int((collectionViewWidth - totalSpacing)/numberOfItemsPerRow)
        let CellHeight = Int((collectionViewHeight/2))
        return CGSize(width: CellWidth, height: CellHeight)
    }
}
