//
//  DetailInfoCell.swift
//  WhosDown
//
//  Created by chris davis on 4/28/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit

class DetailInfoCell: UITableViewCell {
    
    class DetailLabel: UILabel {
        override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 5)
            super.drawText(in: rect.inset(by: insets))
        }
    }
    
    let label: DetailLabel = {
        let label = DetailLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.minimumScaleFactor = 0.2
        label.textColor = UIColor.lightGray
        return label
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textContainerInset = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        tv.isScrollEnabled = false
        return tv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        addSubview(textView)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            label.leftAnchor.constraint(equalTo: self.leftAnchor),
            label.rightAnchor.constraint(equalTo: self.rightAnchor),
            label.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/16)
            ])
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: label.bottomAnchor),
            textView.leftAnchor.constraint(equalTo: self.leftAnchor),
            textView.rightAnchor.constraint(equalTo: self.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
