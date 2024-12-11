//
// File name: MenuTabBarViewController.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit

class MenuTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        setupTabBarView()
    }
    
    private func setupTabBarView(){
        tabBar.tintColor = .backgroundAsset
        tabBar.barTintColor = .systemBackground
        tabBar.backgroundColor = .systemBackground
        tabBar.layer.masksToBounds = true
        let height = tabBar.frame.size.height/2
        tabBar.frame.size.height = height
        tabBar.frame.origin.y = tabBar.frame.size.height - height
    }
    
    private func setupTabBar(){
        let items: [UINavigationController] = [
            prepareTabController(vc: MainViewController(), title: "Main", image: UIImage(systemName: "photo.on.rectangle.angled"), tag: 0),
            prepareTabController(vc: SecondViewController(), title: "Capture", image: UIImage(systemName: "camera.viewfinder"), tag: 1),
            prepareTabController(vc: ThirdViewController(), title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 2),
            prepareTabController(vc: ForthViewController(), title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
        ]
        setViewControllers(items, animated: true)
    }
    
    private func prepareTabController(vc: UIViewController, title: String, image: UIImage?,tag: Int) -> UINavigationController {
        vc.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        return MenuNavigationViewController(rootViewController: vc)
    }

}
