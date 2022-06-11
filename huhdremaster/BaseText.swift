import SpriteKit

class BaseText: SKLabelNode {
    var _scene: BaseScene? = nil
    
    override init() {
        super.init()
        self.fontName = "M46_LOSTPET"
        self.fontColor = UIColor(red: 255/255, green: 62/255, blue: 166/255, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func setScene(scene: BaseScene) {
        self.fontSize = 22 * scene.scaleFactor
        scene.addChild(self)
        self._scene = scene
    }
    
    func cleanup() {
        
    }
}

class ShadowedText: BaseText {
    var shadow: BaseText = BaseText()
    
    override init() {
        super.init()
        self.shadow.fontColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func setText(text: String) {
        self.text = text
        self.shadow.text = text
    }
    
    func setZ(zPos: CGFloat) {
        self.zPosition = zPos
        self.shadow.zPosition = zPos - 1
    }
    
    func setHidden(hidden: Bool) {
        self.isHidden = hidden
        self.shadow.isHidden = hidden
    }
    
    func setPosition(pos: CGPoint) {
        self.position = pos
        self.shadow.position = CGPoint(x: pos.x + 2, y: pos.y - 2)
    }
    
    override func setScene(scene: BaseScene) {
        super.setScene(scene: scene)
        self.shadow.setScene(scene: scene)
    }
    
    override func cleanup() {
        super.cleanup()
        self.shadow.removeFromParent()
    }
}
