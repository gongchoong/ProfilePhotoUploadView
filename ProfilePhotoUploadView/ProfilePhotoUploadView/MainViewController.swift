//
//  MainViewController.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 10/19/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "blankImage")
        return imageView
    }()
    
    fileprivate let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.9
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    var viewModel: MainViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfLoggedIn()
    }
    
    fileprivate func checkIfLoggedIn(){
        if Auth.auth().currentUser == nil{
            loadLoginViewController()
        }else{
            setup()
        }
    }
    
    func setup(){
        
        viewModel = MainViewModel(self, tableView)
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        tableView.register(UserProfileImageCell.self, forCellReuseIdentifier: UserProfileImageCell.identifier)
        tableView.register(UserProfileMenuCell.self, forCellReuseIdentifier: UserProfileMenuCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Signout", style: .plain, target: self, action: #selector(signOut))
        
        view.addSubview(backgroundImageView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
            ])
        
        blurEffectView.frame = backgroundImageView.bounds
        backgroundImageView.addSubview(blurEffectView)
    }
    
    @objc func signOut(){
        do {
            try Auth.auth().signOut()
            loadLoginViewController()
        } catch let err{
            print(err.localizedDescription)
        }
    }
    
    fileprivate func loadLoginViewController(){
        let loginController = LoginViewController()
        loginController.mainViewController = self
        viewModel?.unassignImagesBeforeSigningOut()
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    func loadUserInfoController(){
        let userInfoController = UserInfoController()
        userInfoController.mainViewController = self
        navigationController?.pushViewController(userInfoController, animated: true)
    }

}
