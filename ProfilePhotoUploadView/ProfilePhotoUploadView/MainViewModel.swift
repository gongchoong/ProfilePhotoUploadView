//
//  MainViewModel.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/28/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum ProfileModelItemType {
    case photos
    case information
    
    func index() -> IndexPath{
        switch self {
        case .photos:
            return IndexPath(row: 0, section: 0)
        case .information:
            return IndexPath(row: 1, section: 0)
        }
    }
}

protocol ProfileModelItem{
    var type: ProfileModelItemType {get}
    var name: String {get}
}

class MainViewModel: NSObject{
    
    var tableView: UITableView?
    var items = [ProfileModelItem]()
    weak var mainViewController: MainViewController?
    var user: User?
    
    init(_ tv: UITableView, _ vc: MainViewController) {
        tableView = tv
        mainViewController = vc
    }
    
    func populate(){
        fetchCurrentUser { (user) in
            self.user = user
            self.removeAllItems()
            let photoItem = ProfileModelPhotosItem()
            let infoItem = ProfileModelInformationItem()
            
            self.items.append(photoItem)
            self.items.append(infoItem)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    func removeAllItems(){
        self.items.removeAll()
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    fileprivate func fetchCurrentUser(completion: @escaping(User)->()) {
        // fetch some Firebase Data
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(dictionary)
            completion(user)
        })
    }
}

extension MainViewModel: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.count > 0{
            return items.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.row].type {
        case .photos:
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotoUploadCell.identifier, for: indexPath) as! PhotoUploadCell
            cell.mainViewController = self.mainViewController
            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.identifier, for: indexPath) as! DetailInfoCell
            cell.label.text = self.items[indexPath.row].name
            cell.textView.text = user?.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.items[indexPath.row].type {
        case .photos:
            return screenHeight*0.4
        case .information:
            return screenHeight*0.1
        }
    }
    
    
}

class ProfileModelPhotosItem: ProfileModelItem {
    var type: ProfileModelItemType {
        return .photos
    }
    
    var name: String {
        return "Profile Photo"
    }
    
}

class ProfileModelInformationItem: ProfileModelItem {
    var type: ProfileModelItemType{
        return .information
    }
    
    var name: String{
        return "Name"
    }

}
