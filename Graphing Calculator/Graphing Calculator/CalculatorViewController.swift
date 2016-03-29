//
//  ViewController.swift
//  Calculator
//
//  Created by Lucas Kane on 2/9/16.
//  Copyright © 2016 Lucas Kane. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet var display: UILabel!
    @IBOutlet var history: UILabel!
    
    var userInMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if !(digit == "." && display.text!.rangeOfString(".") != nil){
            
            
            if userInMiddleOfTypingANumber {
                display.text = display.text! + digit
            } else {
                display.text = digit
                userInMiddleOfTypingANumber = true
            }
        }
        
        
        
        
        
    }
    @IBAction func operate(sender: UIButton) {
        if userInMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation){
                displayValue = result
            }
            else {
                displayValue = 0
            }
        }
        print(brain.description)
    }
    
    
    @IBAction func clear() {
        self.brain = CalculatorBrain()
        display.text = "0"
        userInMiddleOfTypingANumber = false
        history.text = nil
    }
    
    
    @IBAction func enter() {
        userInMiddleOfTypingANumber = false
        if let value = displayValue {
            if let result = brain.pushOperand(value){
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        
    }
    
    
    @IBAction func setVariable() {
        if displayValue != nil {
            brain.variableValues["M"] = displayValue
            if let result = brain.evaluate() {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        userInMiddleOfTypingANumber = false
        
    }
    
    
    
    @IBAction func pushVariable() {
        if userInMiddleOfTypingANumber {
            enter()
        }
        if let result = brain.pushOperand("M") {
            displayValue = result
        } else {
            displayValue = nil
        }
        
        
    }
    
    var displayValue: Double? {
        get {
            
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
                
            }
            else {
                display.text = " "
                
                
            }
            history.text = brain.description
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination: UIViewController? = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphingViewController {
            gvc.program = brain.program
            if let graphLabel = brain.description {
                gvc.graphLabel = graphLabel
            }
        }
    }}