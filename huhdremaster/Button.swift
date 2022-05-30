//
//  Button.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/30/22.
//

import SpriteKit


class TextButton {
    let buttonBackground: BaseSprite = BaseSprite(imageNamed: "MenuItems_BG.png")
    let buttonText: BaseText = BaseText()
    var _scene: BaseScene?
    
    init(text: String) {
        buttonText.text = text
        buttonText.text = "Start"
    }
    
    func setScene(scene: BaseScene) {
        buttonBackground.setScene(scene: scene)
        buttonText.setScene(scene: scene)
        _scene = scene
    }
    
    func setZ(zPosition: CGFloat) {
        buttonBackground.zPosition = zPosition
        buttonText.zPosition = zPosition + 1
    }
    
    func setPosition(position: CGPoint) {
        buttonBackground.position = position
        buttonText.position = CGPoint(x:buttonBackground.position.x,
                                      y:buttonBackground.position.y - 8 * _scene!.scaleFactor)
    }
}
