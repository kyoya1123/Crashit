import SceneKit

class ItemNode: SCNNode {
    
    var type: ItemType!
    
    init(type: ItemType, destination: SCNVector3) {
        super.init()
        self.type = type
        let geometry = SCNBox(width: 0.1, height: 0.1, length: 0.05, chamferRadius: 10)
        let itemBase = SCNMaterial()
        itemBase.diffuse.contents = UIImage(named: "itemTexture-base")?.texturelize()
        let itemTexture = SCNMaterial()
        let textureImage = UIImage(named: type.rawValue)?.texturelize()
        itemTexture.diffuse.contents = textureImage
        geometry.materials = [itemTexture, itemBase, itemBase, itemBase, itemBase, itemBase]
        geometry.materials.forEach { $0.lightingModel = .constant }
        self.geometry = geometry
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        self.physicsBody?.categoryBitMask = NodeType.item.rawValue
        self.physicsBody?.contactTestBitMask = NodeType.reflector.rawValue
        self.runAction(SCNAction.sequence([SCNAction.move(to: destination, duration: 3)])) {
            self.removeFromParentNode()
        }
        self.name = "item"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum ItemType: String {
    case addBall = "itemTexture-ball"
    case expandReflector = "itemTexture-expand"
    case doubleScore = "itemTexture-double"
}
