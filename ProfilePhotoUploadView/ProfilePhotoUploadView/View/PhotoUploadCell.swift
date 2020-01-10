//
//  PhotoUploadCell.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/29/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

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
    let hud = JGProgressHUD(style: .light)
    var userInfoController: UserInfoController?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    fileprivate func setup(){
        activateHUD()
        getProfileImageArrayFromURLs { (imageDic, user) in
            self.getPermutationArray(imageDic.count, completion: { (permutationArray) in
                self.model = PhotoUploadModel(self.collectionView, imageDic, user, permutationArray, self.userInfoController)
                self.collectionView.dataSource = self.model
                self.collectionView.delegate = self.model
                self.collectionView.dragInteractionEnabled = true
                self.collectionView.dropDelegate = self.model
                self.collectionView.dragDelegate = self.model
                self.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
                
                self.deActivateHUD()
                
                self.addSubview(self.collectionView)
                NSLayoutConstraint.activate([
                    self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
                    self.collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
                    self.collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
                    self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                    ])
            })
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
    
    //get proflie image urls of current user from the db, then assign the urls to the startingUrlArray in MainViewModel
    fileprivate func getProfileImageArrayFromURLs(completion: @escaping([String : (UIImage, Bool)], User)->()){
        fetchCurrentUser { (user) in
            if let imageDic = user.imageUrls{
                var imageArray: [String : (UIImage, Bool)] = [:]
                let addressForUrl1 = imageDic["url1"]
                let addressForUrl2 = imageDic["url2"]
                let addressForUrl3 = imageDic["url3"]
                let addressForUrl4 = imageDic["url4"]
                let addressForUrl5 = imageDic["url5"]
                let addressForUrl6 = imageDic["url6"]
                self.getImage(addressForUrl1, completion: { (result1) in
                    if let image1 = result1{
                        imageArray["1"] = (image1,false)
                        self.userInfoController?.viewModel?.startingUrlArray["1"] = addressForUrl1
                    }
                    self.getImage(addressForUrl2, completion: { (result2) in
                        if let image2 = result2{
                            imageArray["2"] = (image2, false)
                            self.userInfoController?.viewModel?.startingUrlArray["2"] = addressForUrl2
                        }
                        self.getImage(addressForUrl3, completion: { (result3) in
                            if let image3 = result3{
                                imageArray["3"] = (image3, false)
                                self.userInfoController?.viewModel?.startingUrlArray["3"] = addressForUrl3
                            }
                            self.getImage(addressForUrl4, completion: { (result4) in
                                if let image4 = result4{
                                    imageArray["4"] = (image4, false)
                                    self.userInfoController?.viewModel?.startingUrlArray["4"] = addressForUrl4
                                }
                                self.getImage(addressForUrl5, completion: { (result5) in
                                    if let image5 = result5{
                                        imageArray["5"] = (image5, false)
                                        self.userInfoController?.viewModel?.startingUrlArray["5"] = addressForUrl5
                                    }
                                    self.getImage(addressForUrl6, completion: { (result6) in
                                        if let image6 = result6{
                                            imageArray["6"] = (image6, false)
                                            self.userInfoController?.viewModel?.startingUrlArray["6"] = addressForUrl6
                                            completion(imageArray, user)
                                        }else{
                                            completion(imageArray, user)
                                        }
                                    })
                                })
                            })
                        })
                    })
                })
            }else{
                completion([String : (UIImage, Bool)](), user)
            }
        }
    }
    
    fileprivate func getImage(_ address: String?, completion: @escaping(UIImage?)->()){
        if let _address = address{
            if let url = URL(string: _address) {
                if let data = try? Data(contentsOf: url){
                    completion(UIImage(data: data))
                }else{
                    completion(nil)
                }
            }else{
                completion(nil)
            }
        }else{
            completion(nil)
        }
    }
    
    //assign each image's starting position to permutationArray
    fileprivate func getPermutationArray(_ imageDicCount: Int, completion: @escaping([String])->()){
        var array: [String] = []
        if imageDicCount > 0{
            for i in 1...imageDicCount{
                array.append("\(i)")
            }
            completion(array)
        }else{
            completion(array)
        }
    }
    
    fileprivate func retrieveImageArrayFromDictionary(completion: @escaping([String], User)->()){
        fetchCurrentUser { (user) in
            var imageArray: [String] = []
            if let imageDic = user.imageUrls{
                for i in 1...imageDic.count{
                    if let imageUrl = imageDic["url\(i)"]{
                        imageArray.append(imageUrl)
                    }
                    completion(imageArray, user)
                }
            }else{
                completion(imageArray, user)
            }
        }
    }
    
    fileprivate func activateHUD(){
        if let screen = UIApplication.shared.keyWindow{
            self.hud.textLabel.text = "Loading profile photos..."
            self.hud.show(in: screen)
        }
    }
    
    fileprivate func deActivateHUD(){
        if self.hud.isVisible{
            self.hud.dismiss()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }

}
