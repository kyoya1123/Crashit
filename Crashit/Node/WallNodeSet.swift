import SceneKit

class WallNodeSet: NSObject {
    
    var backWall: BackWall!
    var roundWalls = [RoundWall]()
    var depth: CGFloat!
    var thickness: CGFloat!
    
    init(width: CGFloat, height: CGFloat, depth: CGFloat, thickness: CGFloat, position: SCNVector3) {
        super.init()
        self.depth = depth
        self.thickness = thickness
        backWall = BackWall(width, height, thickness, position)
        for i in 0..<4 {
            let roundWall = RoundWall(depth, height, thickness)
            let baseZ = backWall.position.z + Float(thickness) / 2 + Float(depth / 2)
            var position: SCNVector3!
            switch i {
            case 0:
                let baseX = backWall.position.x - Float(width) / 2 + Float(thickness / 2)
                position = SCNVector3(baseX, backWall.position.y, baseZ)
                roundWall.eulerAngles.y = -.pi / 2
                roundWall.name = "w-left"
            case 1:
                let baseX = backWall.position.x + Float(width) / 2 - Float(thickness / 2)
                position = SCNVector3(baseX, backWall.position.y, baseZ)
                roundWall.eulerAngles.y = -.pi / 2
                roundWall.name = "w-right"
            case 2:
                let baseY = backWall.position.y - Float(height) / 2 + Float(thickness / 2)
                position = SCNVector3(backWall.position.x, baseY, baseZ)
                roundWall.eulerAngles.x = -.pi / 2
                roundWall.eulerAngles.y = -.pi / 2
                roundWall.name = "w-bottom"
            case 3:
                let baseY = backWall.position.y + Float(height) / 2 - Float(thickness / 2)
                position = SCNVector3(backWall.position.x, baseY, baseZ)
                roundWall.eulerAngles.x = -.pi / 2
                roundWall.eulerAngles.y = -.pi / 2
                roundWall.name = "w-top"
            default:
                break
            }
            roundWall.position = position
            roundWalls.append(roundWall)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var borderCoordinate: [Float] {
        return [roundWalls[0].worldPosition.x, roundWalls[1].worldPosition.x, roundWalls[2].worldPosition.y, roundWalls[3].worldPosition.y, backWall.worldPosition.z, backWall.worldPosition.z + Float(depth)]
    }
    
    var blockArea: [Float] {
        let excess = Float(thickness / 2)
        return [roundWalls[0].worldPosition.x + excess, roundWalls[1].worldPosition.x - excess, roundWalls[2].worldPosition.y + excess, roundWalls[3].worldPosition.y - excess, backWall.worldPosition.z + excess, borderCoordinate[5] - 1.5]
    }
    
    func changeTexture(_ texture: WallTexture) {
        backWall.changeTexture(texture)
        roundWalls.forEach { $0.changeTexture(texture) }
    }
}

class BackWall: SCNNode {
    
    init(_ width: CGFloat, _ height: CGFloat, _ length: CGFloat, _ position: SCNVector3) {
        super.init()
        let geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        geometry.firstMaterial?.lightingModel = .constant
        self.geometry = geometry
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        self.position = position
        self.name = "w-back"
        self.physicsBody?.categoryBitMask = NodeType.wall.rawValue
        self.physicsBody?.collisionBitMask = NodeType.ball.rawValue
        self.physicsBody?.contactTestBitMask = NodeType.ball.rawValue
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.damping = 0
        self.opacity = 0.6
        self.castsShadow = false
        changeTexture(.normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeTexture(_ texture: WallTexture) {
        let texture = UIImage(named: texture.rawValue)!.texturelize()
        self.geometry?.firstMaterial?.diffuse.contents = texture
    }
}

class RoundWall: SCNNode {
    
    init(_ width: CGFloat, _ height: CGFloat, _ length: CGFloat) {
        super.init()
        let geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        geometry.firstMaterial?.lightingModel = .constant
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        self.geometry = geometry
        self.physicsBody?.categoryBitMask = NodeType.wall.rawValue
        self.physicsBody?.collisionBitMask = NodeType.ball.rawValue
        self.physicsBody?.contactTestBitMask = NodeType.ball.rawValue
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.damping = 0
        self.opacity = 0.6
        self.castsShadow = false
        changeTexture(.normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func changeTexture(_ texture: WallTexture) {
        let texture = UIImage(named: texture.rawValue)!.texturelize()
        self.geometry?.firstMaterial?.lightingModel = .constant
        self.geometry?.firstMaterial?.diffuse.contents = texture
    }
}

enum WallTexture: String {
    case normal = "wallTexture-normal"
    case missed = "wallTexture-missed"
}
