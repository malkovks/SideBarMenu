//
// File name: PhotoCropViewController.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 29.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit

class PhotoCropViewController: UIViewController {
    private lazy var cropContainer: UIView = {
        let size = UIScreen.main.bounds.width
        let yOffset = (UIScreen.main.bounds.height - size) / 2 
        let view = UIView(frame: CGRect(x: 0, y: yOffset, width: size, height: size))
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var initialImageFrame: CGRect = .zero
    private var lastScale: CGFloat = 1.0

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black


        view.addSubview(cropContainer)
        cropContainer.addSubview(imageView)//incorrect work
        
        setupImageFrame()
        configureGestures()
        configureDrawGrid()
        hidesBottomBarWhenPushed = true
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveResult))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc private func didTapSaveResult(){
        guard let image = imageView.image else {return }
        let cropRect = cropContainer.convert(cropContainer.bounds, to: imageView)
        
        let scaleX = image.size.width / imageView.bounds.width
        let scaleY = image.size.height / imageView.bounds.height
        
        let scaledCropRect = CGRect(x: cropRect.origin.x * scaleX, y: cropRect.origin.y * scaleY, width: cropRect.width * scaleX, height: cropRect.height * scaleY)
        guard let croppedCGImage = image.cgImage?.cropping(to: scaledCropRect) else { return }
        let croppedImage = UIImage(cgImage: croppedCGImage,scale: image.scale, orientation: image.imageOrientation)
        let vc = PhotoPreviewViewController(image: croppedImage)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupImageFrame() {
        guard let image = imageView.image else { return }
        
        let imageRatio = image.size.width / image.size.height
        let screenRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
        
        if imageRatio > screenRatio {
            let width = UIScreen.main.bounds.height * imageRatio
            let xOffset = (UIScreen.main.bounds.width - width) / 2
            imageView.frame = CGRect(x: xOffset, y: 0, width: width, height: UIScreen.main.bounds.height)
        } else {
            let height = UIScreen.main.bounds.width / imageRatio
            let yOffset = (UIScreen.main.bounds.height - height) / 2
            imageView.frame = CGRect(x: 0, y: yOffset, width: UIScreen.main.bounds.width, height: height)
        }
        
        initialImageFrame = imageView.frame
    }
    
    @objc private func didPinchImageView(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            let scale = gesture.scale
            let newWidth = max(initialImageFrame.width, min(imageView.frame.width * scale, initialImageFrame.width * 3))
            let newHeight = max(initialImageFrame.height, min(imageView.frame.height * scale, initialImageFrame.height * 3))
            
            let dx = (imageView.frame.width - newWidth) / 2
            let dy = (imageView.frame.height - newHeight) / 2
            
            imageView.frame = CGRect(x: imageView.frame.origin.x + dx,
                                     y: imageView.frame.origin.y + dy,
                                     width: newWidth,
                                     height: newHeight)
            
            gesture.scale = 1.0
        }
    }

    @objc private func didPanImageView(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        if gesture.state == .began || gesture.state == .changed {
            var newX = imageView.frame.origin.x + translation.x
            var newY = imageView.frame.origin.y + translation.y
            
            let minX = cropContainer.frame.origin.x - (imageView.frame.width - cropContainer.frame.width) / 2
            let maxX = cropContainer.frame.origin.x + (imageView.frame.width - cropContainer.frame.width) / 2
            let minY = cropContainer.frame.origin.y - (imageView.frame.height - cropContainer.frame.height) / 2
            let maxY = cropContainer.frame.origin.y + (imageView.frame.height - cropContainer.frame.height) / 2

            newX = max(minX, min(newX, maxX))
            newY = max(minY, min(newY, maxY))

            imageView.frame.origin = CGPoint(x: newX, y: newY)
            gesture.setTranslation(.zero, in: view)
        }
    }
    
    private func configureGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinchImageView))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanImageView))
        
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(panGesture)
    }
    
    private func configureDrawGrid() {
        let gridLayer = CAShapeLayer()
        gridLayer.strokeColor = UIColor.white.withAlphaComponent(0.6).cgColor
        gridLayer.lineWidth = 1
        
        let path = UIBezierPath()
        let step = cropContainer.bounds.width / 3
        for i in 1..<3 {
            path.move(to: CGPoint(x: step * CGFloat(i), y: 0))
            path.addLine(to: CGPoint(x: step * CGFloat(i), y: cropContainer.bounds.height))
            
            path.move(to: CGPoint(x: 0, y: step * CGFloat(i)))
            path.addLine(to: CGPoint(x: cropContainer.bounds.width, y: step * CGFloat(i)))
        }
        gridLayer.path = path.cgPath
        cropContainer.layer.addSublayer(gridLayer)
    }
}

