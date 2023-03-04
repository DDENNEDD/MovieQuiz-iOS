import Foundation


struct GameRecord: Codable, Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
    var correct: Int
    var total: Int
    var date: Date
}
