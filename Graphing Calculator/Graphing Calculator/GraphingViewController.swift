//
//  GraphViewController.swift
//  Graphing Calculator
//
//  Created by Lucas Kane on 3/15/16.
//  Copyright © 2016 Lucas Kane. All rights reserved.
//


import UIKit

class GraphingViewController: UIViewController, GraphViewDataSource  {
    //Calculator Brain is an optional because what if there is no equation to graph ?
    var brain:CalculatorBrain?
    var graphTitle: String? {
        didSet{
            self.title = graphTitle
        }
    }
    
    @IBOutlet var graphView: GraphView!{
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView,action: "scale:"))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView,action: "pan:"))
            
            var doubleTap = UITapGestureRecognizer(target: graphView, action: "moveOrigin:")
            doubleTap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTap)
        }
    }
    
    func yCoordinate(sender: GraphView,xCoordinate: CGFloat) -> CGFloat? {
        brain?.variableValues["M"] = Double(xCoordinate)
        if let y = brain?.evaluate(){
            return CGFloat(y)
        }
        return nil
    }
    
    
}
