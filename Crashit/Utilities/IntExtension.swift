import Foundation

extension Int {
    //タイマーの表示
    var timerFormat: String {
        switch self {
        case 0...9:
            return "0:0\(self)"
        default:
            return "0:\(self)"
        }
    }
}
