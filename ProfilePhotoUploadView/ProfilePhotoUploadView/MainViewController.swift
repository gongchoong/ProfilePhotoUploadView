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

class MainViewController: UIViewController {
    
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewModel: MainViewModel?

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
    }
    
    func setupViewModel(){
        viewModel = MainViewModel(tableView)
        print("viewmodel is initialized")
        
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
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
            populateViewModel()
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
        
        viewModel?.removeAllItems()
        let loginViewController = LoginViewController()
        loginViewController.mainViewController = self
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    fileprivate func populateViewModel(){
        if let model = viewModel{
            model.populate()
        }
    }
}

