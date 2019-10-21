//
//  UserProfileMenuCell.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 10/20/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit

class UserProfileMenuCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Lato-Bold", size: 18)
        label.textColor = UIColor.white
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    let topDivierLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let botDivierLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    fileprivate func setup(){
        backgroundColor = UIColor.clear
        addSubview(topDivierLine)
        addSubview(botDivierLine)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            topDivierLine.topAnchor.constraint(equalTo: topAnchor),
            topDivierLine.centerXAnchor.constraint(equalTo: centerXAnchor),
            topDivierLine.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            topDivierLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor),
            
            botDivierLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            botDivierLine.centerXAnchor.constraint(equalTo: centerXAnchor),
            botDivierLine.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            botDivierLine.heightAnchor.constraint(equalToConstant: 0.5)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
