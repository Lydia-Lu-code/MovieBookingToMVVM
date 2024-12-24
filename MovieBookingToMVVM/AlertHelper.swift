import UIKit

class AlertHelper {
    static func showAlert(
        in viewController: UIViewController,
        title: String = "提示",
        message: String,
        handler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            handler?()
        })
        viewController.present(alert, animated: true)
    }
}

