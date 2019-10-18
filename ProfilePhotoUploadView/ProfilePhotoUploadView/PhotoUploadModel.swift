//
//  PhotoUploadModel.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/29/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol ProfileImageUploadModelDelegate: class {
    func presentPhotoPermissionDeniedAlert()
    func presentImagePicker(_ indexPath: IndexPath)
}

class PhotoUploadModel: NSObject {
    
    var collectionView: UICollectionView?
    var permutationArray: [String] = []
    var imageDic: [String: (UIImage, Bool)]?
    var loggedInUser: User?
    let itemCount = 6
    var delegate: ProfileImageUploadModelDelegate?
    
    fileprivate let emptyImage = UIImage(named: "addImg")
    
    init(_ cv: UICollectionView, _ dic: [String: (UIImage, Bool)], _ user: User, _ perm: [String], _ vc: MainViewController?) {
        collectionView = cv
        imageDic = dic
        loggedInUser = user
        permutationArray = perm
        delegate = vc
    }
    
    func setCellEmpty(_ cell: ImageCell){
        cell.imageView.image = emptyImage
        cell.imageDeleteButton.isEnabled = false
        cell.imageDeleteButton.isHidden = true
        cell.applyDottedBorder()
    }
    
    func setCellImage(_ cell: ImageCell, _ image: UIImage, _ isChanged: Bool, _ indexPath: IndexPath){
        cell.imageView.image = image
        cell.isChanged = isChanged
        cell.imageDeleteButton.addTarget(self, action: #selector(handleImageDelete), for: .touchUpInside)
        cell.imageDeleteButton.tag = indexPath.row
        cell.imageDeleteButton.isEnabled = true
        cell.imageDeleteButton.isHidden = false
        cell.shapeLayer.removeFromSuperlayer()
    }
    
    func addImageToImageDic(_ selectedCell: ImageCell, _ image: UIImage, _ indexPath: IndexPath){
        let position = indexPath.row
        let permutationArrayCount = permutationArray.count
        if permutationArrayCount < position + 1{
            //add new image
            let emptySpace = findFirstEmptyImageDicSpace()
            imageDic?["\(emptySpace)"] = (image, true)
            permutationArray.insert("\(emptySpace)", at: permutationArrayCount)
            selectedCell.isChanged = true
            
        }else{
            //replace an existing image
            imageDic?["\(permutationArray[position])"] = (image, true)
            selectedCell.isChanged = true
        }
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    fileprivate func findFirstEmptyImageDicSpace() -> Int{
        if let dictionary = self.imageDic{
            for i in 1...dictionary.count + 1{
                if dictionary["\(i)"] == nil{
                    return i
                }
            }
            return 0
        }else{
            return 0
        }
    }
}

extension PhotoUploadModel: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row < permutationArray.count{
            let item = permutationArray[indexPath.row]
            let itemProvider = NSItemProvider(object: NSString(string: item))
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        }else{
            return [UIDragItem(itemProvider: NSItemProvider())]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath{
            destinationIndexPath = indexPath
        }else{
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move{
            reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView) { (sourceIndex, destinationIndex) in
                self.reassignTagNumber(sourceIndex, destinationIndex)
            }
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView, completion: @escaping(_ sourceIndex: IndexPath, _ destinationIndex: IndexPath)->()){
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath{
            //prevent crash
            if destinationIndexPath.row < permutationArray.count && sourceIndexPath.row < permutationArray.count{
                collectionView.performBatchUpdates({
                    //only changing permutation array not the actual image array
                    permutationArray.remove(at: sourceIndexPath.item)
                    permutationArray.insert(item.dragItem.localObject as! String, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }, completion: nil)
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                completion(sourceIndexPath, destinationIndexPath)
            }
        }
    }
    
    //reassign tags for newly ordered image cells for deletion function
    fileprivate func reassignTagNumber(_ source: IndexPath, _ destination: IndexPath){
        if let collectionView = self.collectionView{
            var start: Int
            var end: Int
            //do not need to start from 0
            if source.row > destination.row{
                start = destination.row
                end = source.row
            }else{
                start = source.row
                end = destination.row
            }
            for i in start...end{
                let indexPath = IndexPath(row: i, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
                cell.imageDeleteButton.tag = i
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        setCellEmpty(cell)
        if indexPath.row < permutationArray.count{
            let index = permutationArray[indexPath.row]
            if let image = imageDic?[index]?.0, let isChanged = imageDic?[index]?.1{
                setCellImage(cell, image, isChanged, indexPath)
            }
            return cell
        }else{
            return cell
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleImageUploader(indexPath)
    }
    
    fileprivate func handleImageUploader(_ indexPath: IndexPath){
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.presentImagePickerAction(indexPath)
            case .denied:
                self.presentPhotoPermissionDeniedAlertAction()
            case .notDetermined:
                self.presentPhotoPermissionDeniedAlertAction()
            case .restricted:
                self.presentPhotoPermissionDeniedAlertAction()
            }
        }
    }
    
    @objc func handleImageDelete(sender: UIButton){
        if let collectionView = self.collectionView{
            let index = sender.tag
            let beingDeletedIndex = permutationArray[index]
            permutationArray.remove(at: index)
            imageDic?.removeValue(forKey: beingDeletedIndex)
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }
    }
    
    fileprivate func presentPhotoPermissionDeniedAlertAction(){
        if let del = delegate{
            del.presentPhotoPermissionDeniedAlert()
        }
    }
    
    fileprivate func presentImagePickerAction(_ indexPath: IndexPath){
        if let del = delegate{
            del.presentImagePicker(indexPath)
        }
    }
}
