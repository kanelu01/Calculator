//
//  ViewController.swift
//  Calculator
//
//  Created by Lucas Kane on 2/9/16.
//  Copyright © 2016 Lucas Kane. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        }else {
            display.text = digit.rangeOfString(".") != nil ? "0" + digit : digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clear();
        userIsInTheMiddleOfTypingANumber = false
        displayValue = 0
        updateHistory()
    }
    

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            
            if let result = brain.performOperation(operation) {
                displayValue = result
        }else{
            displayValue = nil
            }
            
        }
        updateHistory()
    }
    
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
        updateHistory()
    }
    
    
    @IBAction func setM() {
        if displayValue != nil {
            userIsInTheMiddleOfTypingANumber = false
            brain.variableValues["M"] = displayValue
            if let result = brain.evaluate() {
                displayValue = result
            } else {
                displayValue = nil
            }
            updateHistory()
        }
        
    }
    
    
    @IBAction func pushM() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let result = brain.pushOperand("M") {
            displayValue = result
        } else {
            displayValue = nil
        }
        updateHistory()
    }

    
    
    func updateHistory() {
        history.text = brain.description + (!userIsInTheMiddleOfTypingANumber && brain.lastOpIsAnOperation ? "=" : "" )
    }
    
    var displayValue: Double? {
        get {
            if let displayValueAsDouble = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return displayValueAsDouble
            }
            return nil
        }
        set {
            display.text = newValue != nil ? "\(newValue!)" : " "
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

