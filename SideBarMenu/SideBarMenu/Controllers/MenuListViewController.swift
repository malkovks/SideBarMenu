

import UIKit

class MenuListViewController: UIViewController {
    
    private var categories: [MenuCategories] = MenuCategories.allCases
    
    private lazy var buttonConfiguration: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark")
        config.title = "Close"
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.imagePlacement = .trailing
        config.imagePadding = 20
        return config
    }()
    
    private lazy var centerLabel: UILabel = { label in
        label.text = "Menu"
        label.textColor = .textColorAsset
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }(UILabel())
    
    private lazy var tableView: UITableView = { tableView in
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuListTableViewCell.self, forCellReuseIdentifier: MenuListTableViewCell.identifier)
        tableView.backgroundColor = .clear
        return tableView
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    private lazy var closeButton: UIButton = { button in
        button.addTarget(self, action: #selector(dismissView), for: .primaryActionTriggered)
        return button
    }(UIButton(configuration: buttonConfiguration))
    
    public var closeButtonHidden: Bool = false
    public var closeHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        configureLabelView()
        closeButton.isHidden = closeButtonHidden
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerLabel.frame = CGRect(x: 10, y: 10, width: view.safeAreaLayoutGuide.layoutFrame.width - 20, height: 50)
        tableView.frame = CGRect(x: 10, y: centerLabel.frame.maxY + 10, width: view.frame.width - 20, height: view.frame.height / 2)
        closeButton.frame = CGRect(x: view.frame.midX - view.frame.width / 4 , y: centerLabel.frame.height + 10 + tableView.frame.height + 20, width: view.frame.width/2, height: 45)
    }
    
    private func configureLabelView(){
        view.addSubview(centerLabel)
        view.addSubview(tableView)
        view.addSubview(closeButton)
    }
    
    @objc private func dismissView(){
        dismiss(animated: true)
        closeHandler?()
    }
}

extension MenuListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MenuListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuListTableViewCell.identifier, for: indexPath) as? MenuListTableViewCell
        var listConfig = UIListContentConfiguration.cell()
        listConfig.image = UIImage(systemName: "\(indexPath.section).square")
        listConfig.text = categories[indexPath.section].rawValue.capitalized
        listConfig.secondaryText = "Some title at \(indexPath.section) index"
        listConfig.textProperties.alignment = .center
        listConfig.secondaryTextProperties.alignment = .center
        listConfig.imageProperties.tintColor = .textColorAsset
        listConfig.textProperties.color = .textColorAsset
        cell?.contentConfiguration = listConfig
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

#Preview {
    let navVC = MenuNavigationViewController(rootViewController: MenuListViewController())
    return navVC
}


