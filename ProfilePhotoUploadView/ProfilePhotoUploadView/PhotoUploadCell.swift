//
//  PhotoUploadCell.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/29/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit

class PhotoUploadCell: UITableViewCell {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var model: PhotoUploadModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    fileprivate func setup(){
        self.model = PhotoUploadModel(self.collectionView)
        self.collectionView.dataSource = self.model
        self.collectionView.delegate = self.model
//        self.collectionView.dragInteractionEnabled = true
//        self.collectionView.dropDelegate = self.model
//        self.collectionView.dragDelegate = self.model
        self.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
    
//        if self.hud.isVisible{
//        self.hud.dismiss()
//        }
    
        self.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }

}
