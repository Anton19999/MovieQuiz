import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = .zero
    private var currentQuestionIndex: Int = .zero
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    } 
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        disableAnswerButton()
        let givenAnswer = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: Any) {
        disableAnswerButton()
        let givenAnswer = true
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true 
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        print("didFailToLoadData called with error: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.showNetworkError(message: error.localizedDescription) 
        }    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        
        let alertModel = AlertModel(
            title: "Ошибка подключения",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertPresenter = AlertPresenter()
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                alertPresenter.showError(quiz: alertModel, from: strongSelf) {
                    
                }
            }
        }
    }
    
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    } 
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect { correctAnswers += 1 }
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.enableAnswerButton()
            
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService.bestGame
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let bestGameDate = formatDate(bestGame.date)
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let message = "\(text)\n Рекорд: \(bestGame.correct)/\(questionsAmount) (\(bestGameDate)) \n Количество сыгранных квизов: \(statisticService.gamesCount)\n Общая точность: \(accuracy)%"
            
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!"
                                                 , text: message
                                                 , buttonText: "Сыграть еще раз")
            let alertPresenter = AlertPresenter()
            alertPresenter.show(quiz: viewModel, from: self) {  [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    
    private func enableAnswerButton(){
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    private func disableAnswerButton(){
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy, HH:mm"
        return dateFormatter.string(from: date)
    }
    
    
    private func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
}
