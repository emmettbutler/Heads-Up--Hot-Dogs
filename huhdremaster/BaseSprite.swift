import SpriteKit

class BaseSprite: SKSpriteNode {
    var _scene: BaseScene? = nil
    var shouldBeDespawned: Bool = false
    
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
    
    func setRandomPosition() {
        let sideBuffer: Int = 55
        let minHeight: Int = Int(UIScreen.main.bounds.height) / -3
        let maxHeight: Int = Int(UIScreen.main.bounds.height) / 2
        let minX: Int = Int(UIScreen.main.bounds.width) / -2 + sideBuffer
        let maxX: Int = Int(UIScreen.main.bounds.width) / 2 - sideBuffer
        self.position = CGPoint(x:Int.random(in:minX...maxX), y:Int.random(in:minHeight...maxHeight))
    }
}
