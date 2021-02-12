import SceneKit
import UIKit

class BlockNode: SCNNode {
    
    var point: Int!
    
    init(size: CGFloat, colors: [UIColor],  destination: SCNVector3) {
        super.init()
        
        //typeの決定
        let allBlockType = BlockType.allCases
        let index = Int.random(in: 0..<allBlockType.count)
        let blockType = allBlockType[index]
        let geometry = blockType.generateGeometry(size)
        
        //色の決定
        var blockColor: UIColor!
        let randomNum = Int.random(in: 0...99)
        switch randomNum {
        case 0...19:
            blockColor = colors[0]
            point = 300
        case 20...49:
            blockColor = colors[1]
            point = 200
        case 50...99:
            blockColor = colors[2]
            point = 100
        default:
            break
        }
        
        //角度の決定
        let xAngle = Int.random(in: 1...360)
        let yAngle = Int.random(in: 1...360)
        let zAngle = Int.random(in: 1...360)
        self.eulerAngles = SCNVector3(xAngle, yAngle, zAngle)
        
        self.geometry = geometry
        geometry.firstMaterial?.lightingModel = .physicallyBased
        self.geometry!.firstMaterial?.diffuse.contents = blockColor
        self.geometry!.firstMaterial?.emission.contents = blockColor
        self.geometry!.firstMaterial?.emission.intensity = 0.8
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        self.physicsBody?.categoryBitMask = NodeType.block.rawValue
        self.physicsBody?.collisionBitMask = NodeType.ball.rawValue
        self.physicsBody?.contactTestBitMask = NodeType.ball.rawValue | NodeType.explode.rawValue
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.damping = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.damping = 0
        self.opacity = 1
        self.castsShadow = true
        self.name = "block"
        //大きいブロック程速く移動する
        let duration = 50 - (((size * 10) - 1) * 10)
        self.runAction(SCNAction.sequence([SCNAction.move(to: destination, duration: TimeInterval(duration))])) {
            self.removeFromParentNode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum BlockType: CaseIterable {
    case box
    case sphere
    case cylinder
    case cone
    case capsule
    case torus
}

extension BlockType: RawRepresentable {
    typealias RawValue = SCNGeometry
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case is SCNBox: self = .box
        case is SCNSphere: self = .sphere
        case is SCNCylinder: self = .cylinder
        case is SCNCone: self = .cone
        case is SCNCapsule: self = .capsule
        case is SCNTorus: self = .torus
        default: return nil
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .box: return SCNBox()
        case .sphere: return SCNSphere()
        case .cylinder: return SCNCylinder()
        case .cone: return SCNCone()
        case .capsule: return SCNCapsule()
        case .torus: return SCNTorus()
        }
    }
    
    func generateGeometry(_ size: CGFloat) -> SCNGeometry {
        switch self {
        case .box:
            return SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        case .sphere:
            return SCNSphere(radius: size / 2)
        case .cylinder:
            return SCNCylinder(radius: size / 2, height: size)
        case .cone:
            return SCNCone(topRadius: size / 4, bottomRadius: size / 2, height: size)
        case .capsule:
            return SCNCapsule(capRadius: size / 4, height: size)
        case .torus:
            return SCNTorus(ringRadius: size / 3, pipeRadius: size / 4)
        }
    }
}
