//
//  CircularProgressBar.swift
//  Fluid Tracker
//
//  Created by Andrew on 7/5/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CircularProgressBar: UIView {
    
    // Various attributes of the circle
    @IBInspectable var underColor: UIColor = UIColor.black
    @IBInspectable var overColor: UIColor = UIColor.yellow
    @IBInspectable var theLineWidth: CGFloat = 15
    @IBInspectable var theStrokeEnd: CGFloat = 0
    
    // The actual layer itself
    let progressCircle = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        self.addCircles()
    }
    
    // Changes the current number of fluids
    func animateStrokeEnd(toStroke: CGFloat) {
        self.progressCircle.strokeEnd = toStroke
    }
    
    // Build the circles and sets up the appearance and everything
    func addCircles() {
        // This is the bottom circle
        let circle = CAShapeLayer()
        let circleWidth = self.frame.height - theLineWidth
        let circleHeight = self.frame.width - theLineWidth
        let circlePath = UIBezierPath(ovalIn: CGRect(x: theLineWidth / 2,
                                                     y: theLineWidth / 2,
                                                     width: circleWidth,
                                                     height: circleHeight))
        
        circle.path = circlePath.cgPath
        circle.strokeColor = underColor.cgColor
        circle.fillColor = UIColor.clear.cgColor
        circle.lineWidth = theLineWidth + 1
        
        // Needed to rotate it and a bunch of other stuff so that it starts at the top
        let transformA = CATransform3DMakeRotation(CGFloat(-90 * Double.pi / 180), 0.0, 0.0, 1.0)
        let transformB = CATransform3DMakeTranslation(0, self.frame.height, 0)
        circle.transform = CATransform3DConcat(transformA, transformB)
        self.layer.addSublayer(circle)
        
        // This is for the top circle
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = overColor.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = theLineWidth
        progressCircle.strokeStart = 0
        progressCircle.transform = CATransform3DConcat(transformA, transformB)
        progressCircle.lineCap = kCALineCapRound
        self.layer.addSublayer(progressCircle)
        
    }
    
}
