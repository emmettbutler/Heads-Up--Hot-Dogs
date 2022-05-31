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
    
    func setRandomPosition() {
        self.position = CGPoint(x:Int.random(in:(Int)(UIScreen.main.bounds.width / -2)...(Int)(UIScreen.main.bounds.width / 2)),
                                y:Int.random(in:(Int)(UIScreen.main.bounds.height / -2)...(Int)(UIScreen.main.bounds.height / 2)))
    }
}
