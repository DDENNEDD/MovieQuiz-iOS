import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    
    
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var NoButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private let presenter = MovieQuizPresenter()
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private var firstQuestion = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
        
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        showLoadingIndicator()
        presenter.yesButtonClicked()
       
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        showLoadingIndicator()
        presenter.noButtonClicked()
        
    }
    
 
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        YesButton.isEnabled = true
        NoButton.isEnabled = true
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        YesButton.isEnabled = false
        NoButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    
    private func show(quiz result: QuizResultsViewModel) {
        alertPresenter?.show(alertModel: AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }))
    }
    
    
    private func showNextQuestionOrResults() {
        hideLoadingIndicator()
        guard presenter.isLastQuestion() == true else {
            self.presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
            return
        }
        guard let statisticService = statisticService else { return }
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        let title = "Этот раунд окончен!"
        let buttonText = "Сыграть ещё раз"
        let text = """
                            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                            Количество сыгранных квизов: \(statisticService.gamesCount)
                            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                            """
        let viewModel = QuizResultsViewModel(
            title: title,
            text: text,
            buttonText: buttonText)
        show(quiz: viewModel)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
    }
    

    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let title = "Ошибка"
        let buttonText = "Попробовать ещё раз"
        let model = AlertModel(title: title,
                               message: message,
                               buttonText: buttonText) { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.show(alertModel: model)
        questionFactory?.loadData()
        showLoadingIndicator()
    }
    
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
}

