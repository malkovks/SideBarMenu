import UIKit

extension UIViewController {
    func presentAlert(title: String){
        let alertController = UIAlertController(title: "Warning", message: title.capitalized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true)
    }
}
