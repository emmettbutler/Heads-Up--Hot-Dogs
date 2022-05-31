import SpriteKit

class BaseScene: SKScene {
    let scaleFactor: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
    
    override init() {
        super.init()
        self.scaleMode = .resizeFill
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getAllLevels() -> Array<Level> {
        return [Philly(), NewYork()]
    }
    
    func levelWithSlug(levelSlug: String) -> Level? {
        for level in getAllLevels() {
            if level.slug == levelSlug {
                return level
            }
        }
        return nil
    }
}
