import UIKit

enum UltimateType {
    case explode
    case split
    case penetrate
    
    var image: UIImage {
        switch self {
        case .explode:
            return UIImage(named: "special-explode")!
        case .split:
            return UIImage(named: "special-split")!
        case .penetrate:
            return UIImage(named: "special-penetrate")!
        }
    }
}
