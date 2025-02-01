//
// File name: FavoriteImageCollectionViewCell.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 01.02.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit

protocol FavoriteImageCollectionViewCellDelegate: AnyObject {
    func didTapMenuButton(at indexPath: IndexPath)
}

class FavoriteImageCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        return $0
    }(UIImageView(frame: .zero))
    
    public lazy var menuButton: UIButton = {
        $0.tintColor = .backgroundAsset
        $0.layer.cornerRadius = $0.frame.width / 2
        $0.setImage(.ellipsis, for: .normal)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(didTapMenuButton), for: .primaryActionTriggered)
        return $0
    }(UIButton(type: .system))
    
    var indexPath: IndexPath?
    weak var delegate: FavoriteImageCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = contentView.frame.size.width
        
        imageView.frame = contentView.bounds
        menuButton.frame = CGRect(x: width - 60, y: 20, width: 40, height: 40)
        menuButton.layer.cornerRadius = menuButton.frame.width / 2
    }
    
    @objc private func didTapMenuButton(){
        guard let indexPath else { return }
        delegate?.didTapMenuButton(at: indexPath)
    }
    
    public func configure(with item: PhotoModel, indexPath: IndexPath){
        self.indexPath = indexPath
        if let image = UIImage(data: item.image){
            imageView.image = image
        }
    }
    
    private func configureCell(){
        contentView.backgroundColor = .backgroundAsset
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.textColorAsset.cgColor
        
        
        contentView.addSubview(imageView)
        contentView.addSubview(menuButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
