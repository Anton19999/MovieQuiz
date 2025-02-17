import UIKit

class AlertPresenter: UIViewController {
    func show(quiz result: QuizResultsViewModel, from viewController: UIViewController, restartAction: @escaping() -> Void) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            restartAction()
            
        }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
