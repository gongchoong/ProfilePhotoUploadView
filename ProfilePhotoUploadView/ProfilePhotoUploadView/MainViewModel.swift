//
//  MainViewModel.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 10/19/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum MainViewItemType {
    case profileImage
    case editProfile
    
    func index() -> IndexPath {
        switch self {
        case .profileImage:
            return IndexPath(row: 0, section: 0)
        case .editProfile:
            return IndexPath(row: 1, section: 0)
        }
    }
}

protocol MainViewItem{
    var type: MainViewItemType {get}
    var title: String {get}
}

class MainViewModel: NSObject {
    
    weak var mainViewController: MainViewController?
    var tableView: UITableView?
    var items = [MainViewItem]()
    var loggedInUser: User?
    
    init(_ vc: MainViewController, _ tv: UITableView) {
        super.init()
        mainViewController = vc
        tableView = tv
        
        getLoggedInUser()
    }
    
    func getLoggedInUser(){
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let user = User(dictionary)
                    self.loggedInUser = user
                    self.setup(user)
                }
            }
        }
    }
    
    fileprivate func setup(_ user: User){
        items.removeAll()
        let profileImageItem = ProfileImageItem()
        let editProfileItem = EditProfileItem()
        
        items.append(profileImageItem)
        items.append(editProfileItem)
        
        if let backgroundImageView = mainViewController?.backgroundImageView{
            setBackgroundImage(user) { (imageData) in
                if imageData != nil{
                    DispatchQueue.main.async {
                        backgroundImageView.image = UIImage(data: imageData!)
                        self.tableView?.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        backgroundImageView.image = UIImage(named: "blankImage")
                        self.tableView?.reloadData()
                    }
                }
            }
        }
    
    }
    
    fileprivate func setBackgroundImage(_ user: User, _ completion: @escaping(Data?) -> ()){
        if let backgroundImageURL = user.getProfileImageUrl(){
            if let url = URL(string: backgroundImageURL){
                getData(url) { (data, response, error) in
                    if error == nil{
                        if let imageData = data {
                            completion(imageData)
                        }else{
                            completion(nil)
                        }
                    }else{
                        completion(nil)
                    }
                    
                }
            }else{
                completion(nil)
            }
        }else{
            completion(nil)
        }
    }
    
    fileprivate func getData(_ url: URL, _ completion: @escaping (Data?, URLResponse?, Error?)->()){
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    fileprivate func assignCellImages(_ cell: UserProfileImageCell){
        if self.loggedInUser?.getProfileImageUrl() != nil{
            cell.profileImageView.image = mainViewController?.backgroundImageView.image
        }else{
            cell.profileImageView.image = UIImage(named: "addImg")
        }
        if let user = loggedInUser{
            cell.nameLabel.text = user.name
        }else{
            cell.nameLabel.text = nil
        }
    }
    
    func unassignImagesBeforeSigningOut(){
       self.loggedInUser = nil
        tableView?.reloadData()
    }
}

extension MainViewModel: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < items.count{
            switch items[indexPath.row].type {
            case .profileImage:
                let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileImageCell.identifier, for: indexPath) as! UserProfileImageCell
                cell.profileImageView.layer.cornerRadius = tableView.frame.size.height * 0.4 * 0.4 * 0.5
                cell.selectionStyle = .none
                assignCellImages(cell)
                return cell
            case .editProfile:
                let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileMenuCell.identifier, for: indexPath) as! UserProfileMenuCell
                cell.titleLabel.text = items[indexPath.row].title
                cell.selectionStyle = .none
                return cell
            }
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch items[indexPath.row].type {
        case .editProfile:
            mainViewController?.loadUserInfoController()
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < items.count{
            switch items[indexPath.row].type {
            case .profileImage:
                return tableView.frame.size.height * 0.4
            case .editProfile:
                return screenHeight * 0.08
            }
        }else{
            return 0
        }
    }
}

class ProfileImageItem: MainViewItem {
    var type: MainViewItemType {
        return .profileImage
    }
    
    var title: String {
        return "Profile Image"
    }
}

class EditProfileItem: MainViewItem {
    var type: MainViewItemType {
        return .editProfile
    }
    
    var title: String {
        return "Edit profile"
    }
}
