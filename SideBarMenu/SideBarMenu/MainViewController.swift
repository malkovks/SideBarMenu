

import UIKit

class MainViewController: UIViewController {
    
    private var isMenuPresented: Bool = false
    private var menuVC: MenuListViewController?
    
    private var menuButton: UIBarButtonItem {
        let image = UIImage(systemName: "list.bullet")!.withTintColor(.red).withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(openMenuVC))
//        button.addSymbolEffect(.pulse)
//        button.isSymbolAnimationEnabled = true
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationItems()
    }
    
    private func configureViewController(){
        view.backgroundColor = .systemBlue
        title = "Module"
    }
    
    private func configureNavigationItems(){
        navigationItem.leftBarButtonItem = menuButton
    }
    
    @objc private func openMenuVC() {
        if isMenuPresented {
            // Если меню открыто, закрываем его
            guard let vc = menuVC else { return }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                vc.view.transform = CGAffineTransform(translationX: -vc.view.frame.width, y: 0)
            } completion: { [weak self] _ in
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
                self?.isMenuPresented = false
                self?.menuVC = nil // Обнуляем ссылку на контроллер
            }
        } else {
            // Если меню закрыто, открываем его
            let vc = MenuListViewController()
            vc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: view.bounds.height)
            
            addChild(vc)
            view.addSubview(vc.view)
            
            vc.didMove(toParent: self)
            
            vc.view.transform = CGAffineTransform(translationX: -vc.view.frame.width, y: 0) // Сдвиг влево
            UIView.animate(withDuration: 0.3) {
                vc.view.transform = .identity // Возвращаем в исходное положение
            }
            
            menuVC = vc // Сохраняем ссылку на контроллер
            isMenuPresented = true // Обновляем флаг
        }
    }
}
