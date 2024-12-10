//
//  MenuNavigationViewController.swift
//  SideBarMenu
//
//  Created by Константин Малков on 24.10.2024.
//

import UIKit

class MenuNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMenuNavigation()
        
    }
    
    private func configureMenuNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .lightBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font : UIFont.systemFont(ofSize: 20, weight: .semibold)]
        
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        
        navigationBar.isTranslucent = false
        
        let largeAttribute: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 28, weight: .bold)]
        navigationBar.largeTitleTextAttributes = largeAttribute
        
        navigationBar.tintColor = .red
        navigationBar.barTintColor = .yellow
    }
}
