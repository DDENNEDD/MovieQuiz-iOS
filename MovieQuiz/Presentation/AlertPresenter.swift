import UIKit


class AlertPresenter {
    
    
    weak var viewController: UIViewController?
    init(viewController: UIViewController?) {
    self.viewController = viewController
    }
    
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action: UIAlertAction = UIAlertAction(title: alertModel.buttonText, style: .default)
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
