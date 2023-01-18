import Foundation


protocol StatisticService {
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
    
}


final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {case correct, total, bestGame, gamesCount}
    var totalAccuracy: Double {
        get {
            if userDefaults.integer(forKey: Keys.total.rawValue) != 0 {
                return (Double(userDefaults.integer(forKey: Keys.correct.rawValue)) / Double(userDefaults.integer(forKey: Keys.total.rawValue))) * 100
            } else {
                return 0.0
            }
        }
    }
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let gameResult = GameRecord(
            correct: count,
            total: amount,
            date: Date()
        )
        if bestGame < gameResult {
            bestGame = gameResult
        }
        var correctCount = userDefaults.integer(forKey: Keys.correct.rawValue)
        var totalAmount = userDefaults.integer(forKey: Keys.total.rawValue)
        correctCount += count
        totalAmount += amount
        userDefaults.set(correctCount, forKey: Keys.correct.rawValue)
        userDefaults.set(totalAmount, forKey: Keys.total.rawValue)
        gamesCount += 1
    }
}
