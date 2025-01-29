//
// File name: PhotoCropViewController.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 29.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit

class PhotoCropViewController: UIViewController {
    private lazy var cropContainer: UIView = {
        let size = min(UIScreen.main.bounds.width,UIScreen.main.bounds.height) * 0.8
        $0.frame = CGRect(x: 0, y: 0, width: size, height: size)
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 2
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    private lazy var imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView())
    
    private var lastScale: CGFloat = 1.0
    private var lastTranslation: CGPoint = .zero
    
    init(image: UIImage){
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        cropContainer.center = view.center
        view.addSubview(cropContainer)
        
        imageView.frame = cropContainer.bounds
        cropContainer.addSubview(imageView)
        
        configureGestures()
        configureDrawGrid()
    }
    
    
    
    @objc private func didPinchImageView(_ gesture: UIPinchGestureRecognizer){
        if gesture.state == .began || gesture.state == .changed{
            let scale = gesture.scale
            let newScale = max(1.0, min(lastScale * scale,3.0))//make limit on pinch gesturing
            
            imageView.transform = CGAffineTransform(scaleX: newScale, y: newScale)
        } else if gesture.state == .ended{
            lastScale = imageView.transform.a
        }
    }
    //Does not work correctly
    @objc private func didPanImageView(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: cropContainer)
        
        if gesture.state == .began || gesture.state == .changed{
            let newX = lastTranslation.x + translation.x
            let newY = lastTranslation.y + translation.y
            
            imageView.transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
        } else if gesture.state == .ended {
            lastTranslation = CGPoint(x: imageView.transform.tx, y: imageView.transform.ty)
        }
    }
    
    private func configureGestures(){
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinchImageView))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanImageView))
        
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(panGesture)
    }
    
    private func configureDrawGrid(){
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

