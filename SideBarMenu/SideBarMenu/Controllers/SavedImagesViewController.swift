//
// File name: ThirdViewController.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit
import PhotosUI


class SavedImagesViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        $0.delegate = self
        $0.register(FavoriteImageCollectionViewCell.self, forCellWithReuseIdentifier: FavoriteImageCollectionViewCell.description())
        $0.isPagingEnabled = true
        $0.refreshControl = self.refreshControl
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: .createGridLayout()))
    
    private lazy var refreshControl: UIRefreshControl = {
        $0.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        $0.tintColor = .backgroundAsset
        return $0
    }(UIRefreshControl())
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .backgroundAsset
        $0.backgroundColor = .lightGray.withAlphaComponent(0.5)
        $0.style = .large
        return $0
    }(UIActivityIndicatorView(frame: view.bounds))
    
    private var importImageNavigationButton: UIBarButtonItem {
        return .init(barButtonSystemItem: .add, target: self, action: #selector(didTapImportImage))
    }
    
    //add filter data button in navigation
    
    private enum Section: CaseIterable {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PhotoModel>!
    private let coreDataManager: CoreDataManager = .shared
    private let photoManager: PhotoLibraryManager = .shared
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(collectionView)
        view.addSubview(indicatorView)
        view.bringSubviewToFront(indicatorView)
        collectionView.frame = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondBackgroundAsset
        title = "Saved Images"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = importImageNavigationButton
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @objc private func didTapImportImage(){
        indicatorView.startAnimating()
        photoManager.presentPicker(from: self, delegate: self)
    }
    
    @objc private func reloadData(){
        refreshControl.beginRefreshing()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func loadData(){
        let models: [PhotoModel] = coreDataManager.loadPhotos().compactMap { PhotoModel(from: $0) }
        updateSnapshots(with: models)
    }
    
    private func savePhoto(_ model: PhotoModel){
        print("Save image in media")
        dump(model)
    }
    
    private func deletePhoto(_ model: PhotoModel) {
        coreDataManager.deletePhoto(model)
        loadData()
        dump(model)
    }
    
    private func createMenuFor(model: PhotoModel) -> UIMenu {
        let saveAction = UIAction(title: "Save photo",image: UIImage(systemName: "arrow.down.square.fill")) { _ in
            self.savePhoto(model)
        }
        let deleteAction = UIAction(title: "Delete photo", image: UIImage(systemName: "trash.square.fill"),attributes: [.destructive]) { _ in
            self.deletePhoto(model)
        }
        return UIMenu(title: "", children: [saveAction,deleteAction])
    }
    
    private func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, PhotoModel>(collectionView: collectionView) { collectionView, indexPath, photoModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteImageCollectionViewCell.description(), for: indexPath) as! FavoriteImageCollectionViewCell
            cell.configure(with: photoModel,indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    private func updateSnapshots(with items: [PhotoModel]){
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SavedImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Open preview for image \(indexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        //analogical add some features
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.createMenuFor(model: model)
        }
    }
}

extension SavedImagesViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else {
            indicatorView.stopAnimating()
            return
        }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self, let selectedImage = image as? UIImage else {
                self?.presentAlert(title: "Can't convert image")
                self?.indicatorView.stopAnimating()
                return
            }
            DispatchQueue.main.async {
                self.coreDataManager.savePhoto(selectedImage, title: nil)
                self.loadData()
                self.indicatorView.stopAnimating()
            }
        }
    }
}

extension SavedImagesViewController: FavoriteImageCollectionViewCellDelegate {
    //Add some features
    func didTapMenuButton(at indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
        let menu = createMenuFor(model: model)
        if let cell = collectionView.cellForItem(at: indexPath) as? FavoriteImageCollectionViewCell {
            cell.menuButton.showsMenuAsPrimaryAction = true
            cell.menuButton.menu = menu
        }
    }
}
