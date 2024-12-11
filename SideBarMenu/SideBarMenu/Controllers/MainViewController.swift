

import UIKit

class MainViewController: UIViewController {
    
    private var isMenuPresented: Bool = false
    private var menuVC: MenuListViewController?
    private var selectedTransitionType: TransitionStyle = .transition
    
    private var content: [UnsplashPhotos] = [] {
        didSet {
            loadButton.isHidden = !content.isEmpty
            reloadView()
        }
    }
    
    private var cacheImages: [String: UIImage] = [:]
    
    
    private lazy var mainView: ImagesCollectionView = { view in
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        return view
    }(ImagesCollectionView())
    
    private lazy var configuration: UIButton.Configuration = {
        var config = UIButton.Configuration.borderedProminent()
        config.title = "Fetch images"
        config.imagePadding = 10
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .secondarySystemBackground
        config.cornerStyle = .dynamic
        config.activityIndicatorColorTransformer = .monochromeTint
        return config
    }()
    
    private var menuButton: UIBarButtonItem {
        let image = UIImage(systemName: "list.bullet")!.withTintColor(.red).withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(openMenuVC))
        return button
    }
    
    private var settingsTransitionButton: UIBarButtonItem {
        let button =  UIBarButtonItem(title: "Settings", image: nil, target: self, action: nil, menu: didTapChangeTransitionStyle())
        return button
    }
    
    private lazy var loadButton: UIButton = { button in
        button.addTarget(self, action: #selector(didTapFetchImages), for: .primaryActionTriggered)
        return button
    }(UIButton(configuration: configuration))

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationItems()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        content = mockPhotos
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadButton.frame = CGRect(x: view.center.x - view.frame.width/4, y: view.center.y, width: view.frame.width/2, height: 45)
        mainView.frame = CGRect(x: 10, y: 0, width: view.frame.width-20, height: view.frame.height)
    }
    
    private func configureViewController(){
        view.backgroundColor = .backgroundAsset
        title = "Module"
    }
    
    private func configureView(){
        
        view.addSubview(mainView)
        view.addSubview(loadButton)
        mainView.refreshControl.addTarget(self, action: #selector(didTapFetchImages), for: .primaryActionTriggered)
    }
    
    private func reloadView(){
        mainView.collectionView.reloadData()
    }
    
    private func configureNavigationItems(){
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = settingsTransitionButton
        navigationItem.leftBarButtonItem?.isHidden = false
    }
    
    private func setupForType(type: TransitionStyle){
        switch type {
        case .transition:
            configureNavigationItems()
            removeMenuFromSuperview()
        case .push:
            configureNavigationItems()
            removeMenuFromSuperview()
        case .addSuperview:
            configureNavigationItems()
        case .gesture:
            navigationItem.rightBarButtonItem = settingsTransitionButton
            removeMenuFromSuperview()
            presentMenuWithGesture()
        }
        isMenuPresented = false
    }
    

    //MARK: - Buttons actions
    //Create method with UIMenu which return all possibles types of presenting menu
    @objc private func didTapChangeTransitionStyle() -> UIMenu{
        let items: [UIAction] = TransitionStyle.allCases.map { type in
            let selected = selectedTransitionType == type
            return UIAction(title: type.title, state: selected ? .on : .off) { [weak self] _ in
                self?.selectedTransitionType = type
                self?.setupForType(type: type)
            }
        }
        return UIMenu(title: "Select transition type",children: items)
    }
    
    @objc private func openMenuVC() {
        switch selectedTransitionType {
        case .transition:
            presentMenuWithTransform()
        case .push:
            presentMenu()
        case .addSuperview:
            addMenuSuperview()
        case .gesture:
            presentMenuWithGesture()
        }
    }
    
    @objc private func didTapFetchImages(){
        loadButton.configuration?.showsActivityIndicator = true
        mainView.refreshControl.beginRefreshing()
        //work correct
        
        UnsplashApiManager.fetchImages(count: 5) { [weak self] models in
            guard let models, let self else {
                print("Empty models data")
                DispatchQueue.main.async {
                    self?.mainView.refreshControl.endRefreshing()
                    self?.loadButton.configuration?.showsActivityIndicator = false
                }
                return
            }
            DispatchQueue.main.async { [unowned self] in
                self.mainView.refreshControl.endRefreshing()
                self.loadButton.configuration?.showsActivityIndicator = false
                self.content = models
                dump(models)
            }
        }
    }
    
    @objc private func didTapScreenGesture(_ gesture: UIScreenEdgePanGestureRecognizer){
        if gesture.state == .recognized {
            toggleMenuController()
        }
    }

    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        if gesture.state == .changed {
            if isMenuPresented {

                if translation.x < 0 {
                    menuVC?.view.frame.origin.x = max(-250, translation.x)
                }
            } else {
                if translation.x > 0 { 
                    menuVC?.view.frame.origin.x = min(0, translation.x)
                }
            }
        } else if gesture.state == .ended {
            if isMenuPresented {
                if translation.x < -100 {
                    closeMenu()
                } else {
                    openMenu()
                }
            } else {
                if translation.x > 100 {
                    openMenu()
                } else {
                    closeMenu()
                }
            }
        }
    }
    
    //MARK: - Setup Gesture
    private func presentMenuWithGesture(){
        menuVC?.view.frame = CGRect(x: -250, y: 0, width: 250, height: view.frame.height)
        menuVC?.didMove(toParent: self)

        navigationItem.leftBarButtonItem?.isHidden = true
        let panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(didTapScreenGesture))
        panGesture.edges = .left
        view.addGestureRecognizer(panGesture)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(gesture)
    }
    
    //MARK: - Adding menu as Superview
    private func addMenuSuperview(){
        navigationItem.leftBarButtonItem?.isHidden = false
        let menu = MenuListViewController()
        if let menuView = menu.view {
            UIView.animate(withDuration: 0, delay: 1, options: .transitionFlipFromLeft) {
                menuView.frame = self.view.bounds
                self.isMenuPresented = true
            } completion: { _ in
                self.view.addSubview(menuView)
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                menu.closeButtonHidden = false
            }
        }
        
        menu.closeHandler = {
            UIView.animate(withDuration: 0, delay: 1, options: .transitionFlipFromRight) {
                self.isMenuPresented = false
            } completion: { _ in
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                menu.view?.removeFromSuperview()
            }
        }
    }
    
    private func presentMenu(){
        navigationItem.leftBarButtonItem?.isHidden = false
        let vc = MenuListViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.closeButtonHidden = false
        present(vc, animated: true)
    }
    
    private func toggleMenuController(){
        toggleMenu()
    }
    
    private func removeMenuFromSuperview(){
        if let menu = MenuListViewController().view, view.subviews.contains(menu) {
            menu.removeFromSuperview()
        }
    }

    private func toggleMenu() {
        isMenuPresented ? closeMenu() : openMenu()
    }

    private func openMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menuVC?.view.frame.origin.x = 0
        }
        isMenuPresented = true
    }

    private func closeMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menuVC?.view.frame.origin.x = -250
        }
        isMenuPresented = false
    }

    
    //MARK: - Setup transfrom presenting and dismissing
    private func presentMenuWithTransform(){
        switch isMenuPresented {
        case true:
            guard let vc = menuVC else {
                return
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                vc.view.transform = CGAffineTransform(translationX: -vc.view.frame.width, y: 0)
            } completion: { [weak self] _ in
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
                self?.isMenuPresented = false
                self?.menuVC = nil
            }
        case false:
            
            let vc = MenuListViewController()
            vc.closeButtonHidden = true
            
            vc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: view.bounds.height)
            
            addChild(vc)
            view.addSubview(vc.view)
            
            vc.didMove(toParent: self)
            
            //set transform coordinates
            vc.view.transform = CGAffineTransform(translationX: -vc.view.frame.width, y: 0)
            UIView.animate(withDuration: 0.3) {
                vc.view.transform = .identity
            }
            
            menuVC = vc
            isMenuPresented = true
        }
    }
}

extension MainViewController: ImageCollectionViewCellDelegate {
    func updateFavoriteStatus(with cell: ImageCollectionViewCell) {
        if let indexPath = mainView.collectionView.indexPath(for: cell) {
            let value = content[indexPath.item]
            //save to local storage
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.id, for: indexPath) as! ImageCollectionViewCell
        cell.isFavorite = false
        cell.delegate = self
        let model = content[indexPath.item]
        if let url = URL(string: model.urls?.regular ?? ""){
            cell.imageView.loadImage(from: url,imageId: model.id, placeholder: nil) { [weak self] image,id in
                guard let self, let image else { return }
                cacheImages[id] = image
            }
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageWidth: CGFloat = CGFloat(content[indexPath.item].width ?? 100)
        let imageHeight: CGFloat = CGFloat(content[indexPath.item].height ?? 200)
        return calculateCellSize(for: imageWidth, imageHeight: imageHeight, in: collectionView.bounds.width, itemsInRow: 1)
    }
    
    private func calculateCellSize(for imageWidth: CGFloat, imageHeight: CGFloat, in collectionViewWidth: CGFloat, itemsInRow: Int) -> CGSize {
        let availableWidth = collectionViewWidth - 20
        let cellWidth = availableWidth / CGFloat(itemsInRow)
        
        let aspectRatio = imageHeight / imageWidth
        let cellHeight = cellWidth * aspectRatio
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}


#Preview {
    let nav = MenuNavigationViewController(rootViewController: MainViewController())
    return nav
}
