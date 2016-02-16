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
    var enable: Bool = true
    let x = M_PI
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        }else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
    }
    
    
    @IBAction func appendPi(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = true
        if display.text != "0" {
            enter()
            display.text = "\(x)"
            enter()
        } else {
            display.text = "\(x)"
            enter()
        }
    }
    
    
    
    @IBAction func decimalPressed(sender: UIButton) {
        let decimal = sender.currentTitle!
        displayValue = M_PI
        if enable && userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + decimal
            enable = false
        }else {
            display.text = decimal
            userIsInTheMiddleOfTypingANumber = true
            enable = false
            
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.removeAll()
        display.text = "0"
        enter()
    }
    

    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        historyStack.append(sender.currentTitle!)
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation {
        case "x": performOperation { $0 * $1 }
        case "/": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "-": performOperation { $1 - $0 }
        case "sqrt": performOperation { sqrt($0) }
        case "cos": performOperation { cos($0) }
        case "sin": performOperation { sin($0) }
        default: break
        }
    }
   
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    @nonobjc
    func performOperation(operation: (Double) -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }

    var operandStack = Array<Double>()
    var historyStack = Array<String>()
    
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        enable = true
        operandStack.append(displayValue)
        historyStack.append(String(displayValue))
        history.text = "\(historyStack)"
        print("operandStack = \(operandStack)")
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

