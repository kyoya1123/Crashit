import Foundation

enum NodeType: Int {
    //NodeのCollisionに使用するBitmask
    case ball = 2
    case wall = 4
    case block = 8
    case reflector = 16
    case item = 32
    case explode = 64
}
