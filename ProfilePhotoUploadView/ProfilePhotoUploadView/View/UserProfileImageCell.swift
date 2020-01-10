//
//  UserProfileImageCell.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 10/20/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit

class UserProfileImageCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabelSpaceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Lato-Bold", size: 20)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    fileprivate func setup(){
        backgroundColor = UIColor.clear
        addSubview(profileImageView)
        addSubview(nameLabelSpaceView)
        nameLabelSpaceView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            profileImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            
            nameLabelSpaceView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            nameLabelSpaceView.leftAnchor.constraint(equalTo: leftAnchor),
            nameLabelSpaceView.rightAnchor.constraint(equalTo: rightAnchor),
            nameLabelSpaceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: nameLabelSpaceView.centerYAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: nameLabelSpaceView.centerXAnchor),
            nameLabel.widthAnchor.constraint(equalTo: widthAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
