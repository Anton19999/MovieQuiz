import UIKit

class AlertPresenter: UIViewController {
    func showError(quiz result: AlertModel, from viewController: UIViewController, restartAction: @escaping () -> Void) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            restartAction()
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    func show(quiz result: QuizResultsViewModel, from viewController: UIViewController, restartAction: @escaping () -> Void) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            restartAction()
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}

