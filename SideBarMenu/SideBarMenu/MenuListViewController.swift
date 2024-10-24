

import UIKit

class MenuListViewController: UIViewController {
    
    private lazy var centerLabel: UILabel = { label in
        label.text = "Menu"
        label.textColor = .black.withAlphaComponent(0.4)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }(UILabel())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        configureLabelView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerLabel.frame = CGRect(x: 10, y: view.frame.minY + 10, width: view.frame.width - 20, height: 50)
    }
    
    private func configureLabelView(){
        view.addSubview(centerLabel)
    }
}
