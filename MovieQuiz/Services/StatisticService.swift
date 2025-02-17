import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard 
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case date
    }
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
      totalCorrectAnswers += count
                let currentResult = GameResult(correct: count, total: amount, date: Date())
                if currentResult.isBetterThan(bestGame) {
                    bestGame = currentResult
                }
    }
    
    var totalCorrectAnswers: Int {
            get {
                storage.integer(forKey: Keys.correct.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.correct.rawValue)
            }
        }
    
    var gameStats: GameResult {
            get {
                let correct = storage.integer(forKey: Keys.correct.rawValue)
                let total = storage.integer(forKey: Keys.bestGame.rawValue)
                let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date() 
                return GameResult(correct: correct, total: total, date: date)
            }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
        }
    
    var gamesCount: Int {
        get {
                storage.integer(forKey: Keys.gamesCount.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.gamesCount.rawValue)
            }
    }
    
    var bestGame: GameResult {
            get {
                let correct = storage.integer(forKey: Keys.bestGame.rawValue + "Correct")
                let total = storage.integer(forKey: Keys.bestGame.rawValue + "Total")
                let date = storage.object(forKey: Keys.bestGame.rawValue + "Date") as? Date ?? Date()
                return GameResult(correct: correct, total: total, date: date)
            }
            set {
                storage.set(newValue.correct, forKey: Keys.bestGame.rawValue + "Correct")
                storage.set(newValue.total, forKey: Keys.bestGame.rawValue + "Total")
                storage.set(newValue.date, forKey: Keys.bestGame.rawValue + "Date")
            }
        }
    
    var totalAccuracy: Double {
        get {
            guard gamesCount > 0 else {
                return 0.0
            }
            let accuracy = Double(totalCorrectAnswers) / Double(gamesCount * 10)
            return accuracy * 100
        }
    }
}
