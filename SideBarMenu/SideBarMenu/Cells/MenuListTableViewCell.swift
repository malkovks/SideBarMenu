//
//  MenuListTableViewCell.swift
//  SideBarMenu
//
//  Created by Константин Малков on 25.10.2024.
//

import UIKit

class MenuListTableViewCell: UITableViewCell {
    
    static let identifier = "MenuListTableViewCell"
    
    private lazy var menuImageView: UIImageView = { imageView in
        imageView.tintColor = .systemGreen
        return imageView
    }(UIImageView())
    
    private lazy var menuLabel : UILabel = { label in
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 24,weight: .semibold)
        label.textAlignment = .natural
        label.numberOfLines = 1
        return label
    }(UILabel())
    
    public func configureMenuListCell(with image: UIImage, and title: String){
        menuImageView.image = image
        menuLabel.text = title
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    private func configureCell(){
        contentView.addSubview(menuImageView)
        contentView.addSubview(menuLabel)
        
        menuImageView.frame = CGRect(x: contentView.frame.width - 40, y: contentView.frame.midY, width: 30, height: 30)
        
        menuLabel.frame = CGRect(x: 20, y: 10, width: contentView.frame.width - 20 - menuImageView.frame.width, height: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
