//
// File name: ImagesCollectionView.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit

class ImagesCollectionView: UIView {
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        return layout
    }()
    
    public lazy var refreshControl: UIRefreshControl = { refreshControl in
        refreshControl.tintColor = .systemRed
        return refreshControl
    }(UIRefreshControl())
    
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.id)
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImagesView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImagesView(){
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
}
