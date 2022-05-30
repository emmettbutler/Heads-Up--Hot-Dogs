import SpriteKit

class BaseScene: SKScene {
    let scaleFactor: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
