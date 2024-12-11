//
// File name: ImageCollectionViewCell.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit

protocol ImageCollectionViewCellDelegate: AnyObject {
    func updateFavoriteStatus(with cell: ImageCollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let id = "ImageCollectionViewCell"
    
    weak var delegate: ImageCollectionViewCellDelegate?
    var isFavorite: Bool = false {
        didSet {
            updateFavoriteButton.setImage(isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    lazy var imageView: UIImageView = { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }(UIImageView())
    
    lazy var updateFavoriteButton: UIButton = { button in
        button.tintColor = .white
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(toggleFavoriteStatus), for: .primaryActionTriggered)
        return button
    }(UIButton(type: .system))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCellView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        updateFavoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        updateFavoriteButton.frame = CGRect(x: contentView.frame.width - 60, y: 10, width: 40, height: 40)
    }
    
    @objc private func toggleFavoriteStatus(){
        isFavorite.toggle()
        delegate?.updateFavoriteStatus(with: self)
    }
    
    private func configureCellView(){
        contentView.layer.cornerRadius = 25
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.systemOrange.cgColor
        contentView.layer.borderWidth = 2
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(imageView)
        contentView.addSubview(updateFavoriteButton)
    }
}

