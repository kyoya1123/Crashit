import SceneKit
import UIKit

class BallNode: SCNNode {
    
    var type: BallType!
    
    init(type: BallType) {
        super.init()
        self.type = type
        let geometry = SCNSphere(radius: type.size)
        geometry.firstMaterial?.lightingModel = .constant
        geometry.firstMaterial?.diffuse.contents = UIImage(named: type.rawValue)?.texturelize()
        self.geometry = geometry
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        self.physicsBody?.categoryBitMask = NodeType.ball.rawValue
        collidesWithBlocks(true)
        self.physicsBody?.contactTestBitMask = NodeType.wall.rawValue | NodeType.block.rawValue | NodeType.reflector.rawValue
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.damping = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.damping = 0
        self.name = "ball"
    }
    
    func useUltimate(_ ultimateType: UltimateType) {
        //Ultimate使用時のエフェクト
        let particleSystem = SCNParticleSystem(named: "special.scnp", inDirectory: "art.scnassets")!
        particleSystem.particleColor = #colorLiteral(red: 1, green: 0.8784313725, blue: 0.07843137255, alpha: 1)
        switch ultimateType {
        case .explode:
            particleSystem.particleSize = type.particleSize * 6
        case .penetrate:
            particleSystem.particleSize = type.particleSize
        default:
            return
        }
        self.addParticleSystem(particleSystem)
    }
    
    func collidesWithBlocks(_ state: Bool) {
        if state {
            self.physicsBody?.collisionBitMask = NodeType.wall.rawValue | NodeType.block.rawValue | NodeType.reflector.rawValue
        } else {
            self.physicsBody?.collisionBitMask = NodeType.wall.rawValue | NodeType.reflector.rawValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum BallType: String, CaseIterable {
    
    case green = "ballTexture-green"
    case blue = "ballTexture-blue"
    case red = "ballTexture-red"
    
    var speed: Float {
        switch self {
        case .green: return 1.2
        case .blue: return 1.5
        case .red: return 1.8
        }
    }
    
    var size: CGFloat {
        switch self {
        case .green: return 0.08
        case .blue: return 0.05
        case .red: return 0.03
        }
    }
    
    var scoreKey: String {
        switch self {
        case .green: return "highScore-green"
        case .blue: return "highScore-blue"
        case .red: return "highScore-red"
        }
    }
    
    var uiColor: UIColor {
        switch self {
        case .green: return #colorLiteral(red: 0.4583249092, green: 0.703823626, blue: 0.4544506669, alpha: 1)
        case .blue: return #colorLiteral(red: 0.1993887722, green: 0.7445340753, blue: 0.8947255015, alpha: 1)
        case .red: return #colorLiteral(red: 1, green: 0.460074544, blue: 0.5498037934, alpha: 1)
        }
    }
    
    var particleSize: CGFloat {
        switch self {
        case .green: return 0.13
        case .blue: return 0.1
        case .red: return 0.08
        }
    }
}
