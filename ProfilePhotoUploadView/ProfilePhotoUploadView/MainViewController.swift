//
//  ViewController.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/26/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FacebookCore
import SDWebImage
import JGProgressHUD

class CustomUIImageView: UIImageView {
    var isChanged: Bool = false
}

class CustomImagePickerController: UIImagePickerController {
    var indexPath: IndexPath?
}

class MainViewController: UIViewController, ProfileImageUploadModelDelegate, UINavigationControllerDelegate{
    func presentImagePicker(_ indexPath: IndexPath) {
        presentPhotoLibrary(indexPath)
    }
    
    func presentPhotoPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Photo Access Required", message: "In order to access your camera roll, we need to access your Photos. Please enable.", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let enableAction = UIAlertAction(title: "enable", style: .default) { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(enableAction)
    }
    
    
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewModel: MainViewModel?
    var startingUrlArray: [String: Any] = [:]
    var docData: [String: Any] = [:]
    let hud = JGProgressHUD(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupViewModel()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    fileprivate func setup(){
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
    }
    
    func setupViewModel(){
        viewModel = MainViewModel(tableView, self)
        viewModel?.populate()
        print("viewmodel is initialized")
        
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        tableView.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.identifier)
        tableView.register(PhotoUploadCell.self, forCellReuseIdentifier: PhotoUploadCell.identifier)
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        checkIfLoggedIn()
    }
    
    fileprivate func checkIfLoggedIn(){
        if Auth.auth().currentUser?.uid != nil{
            //populateViewModel()
        }else{
            let loginViewController = LoginViewController()
            loginViewController.mainViewController = self
            navigationController?.pushViewController(loginViewController, animated: true)
        }
    }
    
    @objc func handleLogout(){
        do{
            try Auth.auth().signOut()
            logoutFromFacebook()
        }catch let error {
            print(error.localizedDescription)
        }
    }

    fileprivate func logoutFromFacebook(){
        let loginManager = LoginManager()
        loginManager.logOut()
        AccessToken.current = nil
        UserProfile.current = nil
        
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func populateViewModel(){
        if let model = viewModel{
            model.populate()
        }
    }
}

extension MainViewController: UIImagePickerControllerDelegate {
    
    @objc func handleSave(){
        if let photoUploadCell = self.tableView.cellForRow(at: ProfileModelItemType.photos.index()) as? PhotoUploadCell, let nameCell = self.tableView.cellForRow(at: ProfileModelItemType.information.index()) as? DetailInfoCell{
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

        uploadIndividualImageToStorage(firstImageData, "1") { (firstImageUrl) in
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
            self.uploadIndividualImageToStorage(secondImageData, "2", { (secondImageUrl) in
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
                self.uploadIndividualImageToStorage(thirdImageData, "3", { (thirdImageUrl) in
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
                    self.uploadIndividualImageToStorage(fourthImageData, "4", { (fourthImageUrl) in
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
                        self.uploadIndividualImageToStorage(fifthImageData, "5", { (fifthImageUrl) in
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
                            self.uploadIndividualImageToStorage(sixthImageData, "6", { (sixthImageUrl) in
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

    fileprivate func uploadIndividualImageToStorage(_ imageData: (UIImage, Bool)?, _ order: String,_ completion: @escaping(String?)->()){
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
        self.hud.textLabel.text = "Saving profile"
        self.hud.show(in: self.view)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    fileprivate func deActivateHUDforSavingProfile(){
        self.hud.dismiss()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    fileprivate func generateEmptyPhotoAlert(){
        let alertController = UIAlertController(title: "You need to upload at least one profile photo", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func presentPhotoLibrary(_ indexPath: IndexPath){
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePickerController = CustomImagePickerController()
                imagePickerController.indexPath = indexPath
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = true
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let image = selectedImageFromPicker {
            let imagePicker = picker as! CustomImagePickerController
            if let selectedIndexPath = imagePicker.indexPath{
                if let tableViewCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PhotoUploadCell{
                    if let selectedImageCell = tableViewCell.collectionView.cellForItem(at: selectedIndexPath) as? ImageCell{
                        tableViewCell.model?.addImageToImageDic(selectedImageCell, image, selectedIndexPath)
                    }
                }
            }
            dismiss(animated: true)
        }
    }
}


fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


