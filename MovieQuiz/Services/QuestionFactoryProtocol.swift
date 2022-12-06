import Foundation


protocol QuestionFactoryProtocol {
    var delegate: MovieQuizViewController { get set }
    func requestNextQuestion()
}
