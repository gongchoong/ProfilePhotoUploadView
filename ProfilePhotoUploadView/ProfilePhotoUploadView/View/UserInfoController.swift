//
//  ViewController.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/26/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit
import SDWebImage

class UserInfoController: UIViewController{
    
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewModel: UserInfoViewModel?
    var mainViewController: MainViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mainViewController?.viewModel?.getLoggedInUser()
    }
    
    fileprivate func setup(){
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        setupViewModel()
    }
    
    func setupViewModel(){
        viewModel = UserInfoViewModel(tableView, self)
        viewModel?.populate()
        
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
    }
    
    @objc func handleSave(){
        if let model = viewModel{
            model.save()
        }
    }
}

extension UserInfoController: ProfileImageUploadModelDelegate {
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
}

extension UserInfoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}


