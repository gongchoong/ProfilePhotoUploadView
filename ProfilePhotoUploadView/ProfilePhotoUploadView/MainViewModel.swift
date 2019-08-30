//
//  MainViewModel.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/28/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import Foundation
import UIKit

enum ProfileModelItemType {
    case photos
    case information
}

protocol ProfileModelItem{
    var type: ProfileModelItemType {get}
    var name: String {get}
}

class MainViewModel: NSObject{
    
    var tableView: UITableView?
    var items = [ProfileModelItem]()
    
    init(_ tv: UITableView) {
        tableView = tv
    }
    
    func populate(){
        removeAllItems()
        let photoItem = ProfileModelPhotosItem()
        let infoItem = ProfileModelInformationItem()
        
        items.append(photoItem)
        items.append(infoItem)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func removeAllItems(){
        self.items.removeAll()
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
            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
            cell.textLabel?.text = items[indexPath.row].name
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
        return "Information"
    }
}
