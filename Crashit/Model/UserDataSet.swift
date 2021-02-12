import Foundation

class UserDataSet: Equatable {
    
    var deviceID: String!
    var name: String!
    var scoreData = [String : Int]()
    
    init(_ data: [String : Any]) {
        BallType.allCases.forEach {
            scoreData[$0.scoreKey] = data[$0.scoreKey] as? Int
        }
        deviceID = data["deviceID"] as? String
        name = data["name"] as? String
    }
    
    static func == (lhs: UserDataSet, rhs: UserDataSet) -> Bool {
        lhs.deviceID == rhs.deviceID
    }
}
