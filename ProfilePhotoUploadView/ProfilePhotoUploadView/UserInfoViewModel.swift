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
import JGProgressHUD

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

class UserInfoViewModel: NSObject{
    
    var tableView: UITableView?
    var items = [ProfileModelItem]()
    weak var userInfoController: UserInfoController?
    var user: User?
    
    var startingUrlArray: [String: Any] = [:]
    var docData: [String: Any] = [:]
    let hud = JGProgressHUD(style: .light)
    
    init(_ tv: UITableView, _ vc: UserInfoController) {
        tableView = tv
        userInfoController = vc
    }
    
    func populate(){
        fetchCurrentUser { (user) in
            self.user = user
            //remove all photo items before to prevent error
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
    
    func save(){
        if let photoUploadCell = self.tableView?.cellForRow(at: ProfileModelItemType.photos.index()) as? PhotoUploadCell, let nameCell = self.tableView?.cellForRow(at: ProfileModelItemType.information.index()) as? DetailInfoCell{
            if let photoUploadModel = photoUploadCell.model{
                if let imageDic = photoUploadModel.imageDic{
                    let permutationArray = photoUploadModel.permutationArray
                    
                    if imageDic.count > 0 && permutationArray.count > 0{
                        activateHUDforSavingProfile()
                        uploadData(imageDic, permutationArray, nameCell) { (result) in
                            if result{
                                print("Finished saving user profile")
                            }else{
                                print("Failed to save user profile")
                            }
                            self.deActivateHUDforSavingProfile()
                            self.userInfoController?.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        generateEmptyPhotoAlert()
                    }
                }
            }
        }
    }
    
    fileprivate func uploadData(_ imageDic: [String: (UIImage, Bool)], _ permutationArray: [String], _ nameCell: DetailInfoCell, _ completion: @escaping (Bool)->()){
        uploadImagesToStorage(imageDic, permutationArray) {
            if let uid = Auth.auth().currentUser?.uid{
                if let name = nameCell.textView.text{
                    self.docData["name"] = name
                }
                
                REF_USERS.child(uid).updateChildValues(self.docData, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        completion(false)
                    }
                    completion(true)
                })
            }
        }
    }
    
    fileprivate func uploadImagesToStorage(_ imageDic: [String: (UIImage, Bool)], _ permutationArray: [String], _ completion: @escaping()->()){
        var firstImageData: (UIImage, Bool)?
        var secondImageData: (UIImage, Bool)?
        var thirdImageData: (UIImage, Bool)?
        var fourthImageData: (UIImage, Bool)?
        var fifthImageData: (UIImage, Bool)?
        var sixthImageData: (UIImage, Bool)?
        
        for i in 0...permutationArray.count - 1{
            if i == 0{
                firstImageData = imageDic[permutationArray[i]]
            }else if i == 1{
                secondImageData = imageDic[permutationArray[i]]
            }else if i == 2{
                thirdImageData = imageDic[permutationArray[i]]
            }else if i == 3{
                fourthImageData = imageDic[permutationArray[i]]
            }else if i == 4{
                fifthImageData = imageDic[permutationArray[i]]
            }else if i == 5{
                sixthImageData = imageDic[permutationArray[i]]
            }
        }
        
        uploadIndividualImageToStorage(firstImageData, 1) { (firstImageUrl) in
            if let url1 = firstImageUrl{
                self.docData["imageUrls/url1"] = url1
            }else{
                if permutationArray.count >= 1{
                    let startingArrayIndexAfterPermutation = permutationArray[0]
                    if let startingUrl1 = self.startingUrlArray[startingArrayIndexAfterPermutation]{
                        self.docData["imageUrls/url1"] = startingUrl1
                    }else{
                        self.docData["imageUrls/url1"] = NSNull()
                    }
                }else{
                    self.docData["imageUrls/url1"] = NSNull()
                }
            }
            self.uploadIndividualImageToStorage(secondImageData, 2, { (secondImageUrl) in
                if let url2 = secondImageUrl{
                    self.docData["imageUrls/url2"] = url2
                }else{
                    if permutationArray.count >= 2{
                        let startingArrayIndexAfterPermutation = permutationArray[1]
                        if let startingUrl2 = self.startingUrlArray[startingArrayIndexAfterPermutation]{
                            self.docData["imageUrls/url2"] = startingUrl2
                        }else{
                            self.docData["imageUrls/url2"] = NSNull()
                        }
                    }else{
                        self.docData["imageUrls/url2"] = NSNull()
                    }
                }
                self.uploadIndividualImageToStorage(thirdImageData, 3, { (thirdImageUrl) in
                    if let url3 = thirdImageUrl{
                        self.docData["imageUrls/url3"] = url3
                    }else{
                        if permutationArray.count >= 3{
                            let startingArrayIndexAfterPermutation = permutationArray[2]
                            if let startingUrl3 = self.startingUrlArray[startingArrayIndexAfterPermutation]{
                                self.docData["imageUrls/url3"] = startingUrl3
                            }else{
                                self.docData["imageUrls/url3"] = NSNull()
                            }
                        }else{
                            self.docData["imageUrls/url3"] = NSNull()
                        }
                    }
                    self.uploadIndividualImageToStorage(fourthImageData, 4, { (fourthImageUrl) in
                        if let url4 = fourthImageUrl{
                            self.docData["imageUrls/url4"] = url4
                        }else{
                            if permutationArray.count >= 4{
                                let startingArrayIndexAfterPermutation = permutationArray[3]
                                if let startingUrl4 = self.startingUrlArray[startingArrayIndexAfterPermutation]{
                                    self.docData["imageUrls/url4"] = startingUrl4
                                }else{
                                    self.docData["imageUrls/url4"] = NSNull()
                                }
                            }else{
                                self.docData["imageUrls/url4"] = NSNull()
                            }
                        }
                        self.uploadIndividualImageToStorage(fifthImageData, 5, { (fifthImageUrl) in
                            if let url5 = fifthImageUrl{
                                self.docData["imageUrls/url5"] = url5
                            }else{
                                if permutationArray.count >= 5{
                                    let startingArrayIndexAfterPermutation = permutationArray[4]
                                    if let startingUrl5 = self.startingUrlArray[startingArrayIndexAfterPermutation]{
                                        self.docData["imageUrls/url5"] = startingUrl5
                                    }else{
                                        self.docData["imageUrls/url5"] = NSNull()
                                    }
                                }else{
                                    self.docData["imageUrls/url5"] = NSNull()
                                }
                            }
                            self.uploadIndividualImageToStorage(sixthImageData, 6, { (sixthImageUrl) in
                                if let url6 = sixthImageUrl{
                                    self.docData["imageUrls/url6"] = url6
                                }else{
                                    if permutationArray.count >= 6{
                                        let startingArrayIndexAfterPermutation = permutationArray[5]
                                        if let startingUrl6 = self.startingUrlArray[startingArrayIndexAfterPermutation]{
                                            self.docData["imageUrls/url6"] = startingUrl6
                                        }else{
                                            self.docData["imageUrls/url6"] = NSNull()
                                        }
                                    }else{
                                        self.docData["imageUrls/url6"] = NSNull()
                                    }
                                }
                                completion()
                            })
                        })
                    })
                })
            })
        }
    }
    
    fileprivate func uploadIndividualImageToStorage(_ imageData: (UIImage, Bool)?, _ order: Int,_ completion: @escaping(String?)->()){
        if let data = imageData{
            if data.1{
                let filename = UUID().uuidString
                let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
                let selectedImage = data.0
                
                guard var uploadData = selectedImage.jpegData(compressionQuality: 1.0) else { return }
                if uploadData.count > MAX_IMAGE_SIZE_BYTES {
                    let compRate = CGFloat(MAX_IMAGE_SIZE_BYTES) / CGFloat(uploadData.count)
                    if let tempData = selectedImage.jpegData(compressionQuality: compRate) {
                        uploadData = tempData
                    }
                }
                
                ref.putData(uploadData, metadata: nil) { (nil, err) in
                    if let err = err {
                        print("Failed to upload image to storage: ", err)
                        completion(nil)
                    }
                    
                    ref.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print("Failed to retrieve download url: ", err)
                            completion(nil)
                        }
                        print("successfully uploaded image \(order))")
                        let imageUrl = url?.absoluteString
                        completion(imageUrl)
                    })
                }
            }else{
                print("image is not changed: not uploading image \(order)")
                completion(nil)
            }
        }else{
            print("data does not exist: image \(order) upload failed")
            completion(nil)
        }
    }
    
    fileprivate func activateHUDforSavingProfile(){
        if let vc = self.userInfoController{
            self.hud.textLabel.text = "Saving profile"
            self.hud.show(in: vc.view)
            vc.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    fileprivate func deActivateHUDforSavingProfile(){
        if let vc = self.userInfoController{
            self.hud.dismiss()
            vc.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    fileprivate func generateEmptyPhotoAlert(){
        if let vc = self.userInfoController{
            let alertController = UIAlertController(title: "You need to upload at least one profile photo", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(action)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}

extension UserInfoViewModel: UITableViewDataSource, UITableViewDelegate{
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
            cell.userInfoController = self.userInfoController
            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.identifier, for: indexPath) as! DetailInfoCell
            cell.label.text = self.items[indexPath.row].name
            cell.textView.text = user?.name
            cell.selectionStyle = .none
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
