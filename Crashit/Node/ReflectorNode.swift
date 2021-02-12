import SceneKit

class ReflectorNode: SCNNode {
    
    init(size: ReflectorSize) {
        super.init()
        let size = CGFloat(size.rawValue)
        let geometry = SCNBox(width: size, height: size * 2, length: 0.01, chamferRadius: 0)
        self.geometry = geometry
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        self.physicsBody?.categoryBitMask = NodeType.reflector.rawValue
        self.physicsBody?.collisionBitMask = NodeType.ball.rawValue
        self.physicsBody?.contactTestBitMask = NodeType.ball.rawValue | NodeType.item.rawValue
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.damping = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.damping = 0
        self.opacity = 0
        self.name = "reflector"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum ReflectorSize: Float {
    case normal = 0.1
    case big = 0.15
}
