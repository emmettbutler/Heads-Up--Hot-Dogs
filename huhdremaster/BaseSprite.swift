import SpriteKit

class BaseSprite: SKSpriteNode {
    var _scene: BaseScene? = nil
    
    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    func setScene(scene: BaseScene) {
        self.xScale = scene.scaleFactor
        self.yScale = scene.scaleFactor
        scene.addChild(self)
        self._scene = scene
    }
}
