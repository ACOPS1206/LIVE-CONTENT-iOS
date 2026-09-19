import ActivityKit
import Foundation

struct LiveContentAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var title: String
        var message: String
        var symbol: String
        var accentHex: String
        var imageData: Data?
        var updatedAt: Date
    }

    var activityID: String
}

