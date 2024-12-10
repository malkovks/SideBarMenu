

import UIKit

class MainViewController: UIViewController {
    
    private var isMenuPresented: Bool = false
    private var menuVC: MenuListViewController?
    private var selectedTransitionType: TransitionStyle = .transition
    
    private var menuButton: UIBarButtonItem {
        let image = UIImage(systemName: "list.bullet")!.withTintColor(.red).withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(openMenuVC))
        return button
    }
    
    private var settingsTransitionButton: UIBarButtonItem {
        let button =  UIBarButtonItem(title: "Settings", image: nil, target: self, action: nil, menu: didTapChangeTransitionStyle())
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationItems()
    }
    
    private func configureViewController(){
        view.backgroundColor = .backgroundAsset
        title = "Module"
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
//            presentMenu()
            configureNavigationItems()
            removeMenuFromSuperview()
        case .addSuperview:
//            addMenuSuperview()
            configureNavigationItems()
        case .gesture:
            navigationItem.rightBarButtonItem = settingsTransitionButton
            removeMenuFromSuperview()
            presentMenuWithGesture()
        }
        isMenuPresented = false
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
    
    @objc private func didTapScreenGesture(_ gesture: UIScreenEdgePanGestureRecognizer){
        if gesture.state == .recognized {
            toggleMenuController()
        }
    }
    
    private func toggleMenuController(){
        toggleMenu()
    }
    
    private func removeMenuFromSuperview(){
        if let menu = MenuListViewController().view, view.subviews.contains(menu) {
            menu.removeFromSuperview()
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        if gesture.state == .changed {
            if isMenuPresented {
                // Закрытие меню
                if translation.x < 0 { // Двигаем влево
                    menuVC?.view.frame.origin.x = max(-250, translation.x)
                }
            } else {
                // Открытие меню
                if translation.x > 0 { // Двигаем вправо
                    menuVC?.view.frame.origin.x = min(0, translation.x)
                }
            }
        } else if gesture.state == .ended {
            if isMenuPresented {
                if translation.x < -100 { // Закрываем, если сдвиг больше 100
                    closeMenu()
                } else {
                    openMenu()
                }
            } else {
                if translation.x > 100 { // Открываем, если сдвиг больше 100
                    openMenu()
                } else {
                    closeMenu()
                }
            }
        }
    }

    func toggleMenu() {
        isMenuPresented ? closeMenu() : openMenu()
    }

    func openMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menuVC?.view.frame.origin.x = 0
        }
        isMenuPresented = true
    }

    func closeMenu() {
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
                //check if menu is presented
                return
            }
            //animation for returning menu out of bounds range
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
            //presenting menu vc
            let vc = MenuListViewController()
            vc.closeButtonHidden = true
            //set size of presenting menu is 80% width of view
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

#Preview {
    let nav = MenuNavigationViewController(rootViewController: MainViewController())
    return nav
}
