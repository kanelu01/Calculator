//
//  GraphingView.swift
//  Graphing Calculator
//
//  Created by Lucas Kane on 3/17/16.
//  Copyright © 2016 Lucas Kane. All rights reserved.
//

import UIKit
import Foundation

protocol GraphViewDataSource: class {
    //send self as it is the proper design pattern for ios
    func yCoordinate(sender: GraphView,xCoordinate: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    // computed property
    @IBInspectable
    var originX:CGFloat = 0 { didSet { setNeedsDisplay() }}
    @IBInspectable
    var originY:CGFloat = 0 { didSet { setNeedsDisplay() }}
    var ppi:CGFloat = 50
    
    @IBInspectable
    var pinchScale:CGFloat = 1 { didSet { setNeedsDisplay() }}
    
    weak var dataSource:GraphViewDataSource?
    
    var scale:CGFloat {
        get {
            return ppi * pinchScale
        }
    }
    var origin:CGPoint {
        get {
            return CGPoint(x:self.center.x + originX,y:self.center.y + originY)
        }
    }
    
    
    
    var firstValue:Bool = true
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            pinchScale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed: fallthrough
        case .Ended:
            let translation = gesture.translationInView(self)
            originX += translation.x
            originY += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func moveOrigin(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            originX = -self.center.x + gesture.locationInView(self).x
            originY = -self.center.y + gesture.locationInView(self).y
        default: break
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        
        let ad = AxesDrawer()
        ad.contentScaleFactor = contentScaleFactor
        ad.drawAxesInRect(self.bounds,origin:origin,pointsPerUnit: scale)
        
        // draw nothing if there is no equation
        if let gds = dataSource {
            let path = UIBezierPath()
            var point = CGPoint()
            for (var i = 0; i < Int(self.bounds.size.width * contentScaleFactor) ; i++) {
                point.x = CGFloat(i) / contentScaleFactor
                
                if let y = dataSource?.yCoordinate(self, xCoordinate: (point.x - origin.x) / scale) {
                    point.y = origin.y - (CGFloat(y) * scale)
                    if firstValue {
                        path.moveToPoint(point)
                        firstValue = false
                    } else {
                        path.addLineToPoint(point)
                    }
                }
                
            }
            
            UIColor.blackColor().setStroke()
            path.lineWidth = 1.0
            path.stroke()
            firstValue = true
            
        }
        //        path.moveToPoint(CGPoint(x: self.bounds.maxX/2, y: self.bounds.maxY/2))
          //      for i in self.bounds.maxX{
          //          if (i % 100 == 0){
          //              let x = i + Int(self.bounds.maxX/2)
          //              let xy =  i*i + Int(self.bounds.maxY/2)
          //              path.addLineToPoint(CGPoint(x: x, y: -xy))
          //          }
          //      }
        
        
        // Drawing code
    }
    
    
}