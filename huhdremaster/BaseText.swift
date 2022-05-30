import SpriteKit

class BaseText: SKLabelNode {
    var _scene: BaseScene? = nil
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func setScene(scene: BaseScene) {
        self.fontName = "M46_LOSTPET"
        self.fontSize = 22 * scene.scaleFactor
        self.fontColor = UIColor(red: 255/255, green: 62/255, blue: 166/255, alpha: 1)
        scene.addChild(self)
        self._scene = scene
    }
}
