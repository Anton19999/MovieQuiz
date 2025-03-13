protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func buttonsOnOff(isEnabled: Bool)
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImage(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}
