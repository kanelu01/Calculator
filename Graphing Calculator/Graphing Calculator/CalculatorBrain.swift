//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Lucas Kane on 2/17/16.
//  Copyright © 2016 Lucas Kane. All rights reserved.
//

import Foundation

enum CalculatorBrainEvaluationResult {
    case Success(Double)
    case Failure(String)
}

class CalculatorBrain{
    private enum Op : CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String,(Double,Double) -> Double)
        case Constant(Double,String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return "\(symbol)"
                case .BinaryOperation(let symbol, _):
                    return "\(symbol)"
                case .Variable(let symbol):
                    // try return "symbol = value"
                    return "\(symbol)"
                case .Constant(_,let symbol):
                    return symbol
                    
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private var error: String?
    
    
    var variableValues = Dictionary<String,Double> ()
    
    private var result:String?
    
    var description: String? {
        var (currentResult,remainingOps) = evaluateDescription(opStack)
        while (remainingOps.isEmpty == false) {
            let (oldResult,newRemainingOps) = evaluateDescription(remainingOps)
            currentResult = oldResult! + ", " + currentResult!
            remainingOps = newRemainingOps
        }
        return currentResult
    }
    
    init() {
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷"){ $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√",sqrt)
        knownOps["π"] = Op.Constant(M_PI,"π")
        knownOps["sin"] = Op.UnaryOperation("sin",sin)
        knownOps["cos"] = Op.UnaryOperation("cos",cos)
        
    }
    
    private func evaluateDescription(ops: [Op]) -> (result:String?, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.minimumFractionDigits = 0
                return (formatter.stringFromNumber(operand),remainingOps)
                
            case .UnaryOperation(let operation, _):
                let operandEvaluation = evaluateDescription(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(operation)(\(operand))" ,operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let operation, _):
                let op1Evaulation = evaluateDescription(remainingOps)
                if let operand1 = op1Evaulation.result {
                    let op2Evaluation = evaluateDescription(op1Evaulation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        if (operation == "×" || operation == "÷") {
                            return ("(\(operand2)) \(operation) (\(operand1))",op2Evaluation.remainingOps)
                        }
                        else {
                            return ("\(operand2) \(operation) \(operand1)",op2Evaluation.remainingOps)
                            
                        }
                        
                        
                    }
                }
            case .Variable(let symbol):
                return ("\(symbol)",remainingOps)
            case .Constant(_,let symbol):
                return ("\(symbol)",remainingOps)
            }
            
        }
        return ("?",ops)
    }
    
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // guaranteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                        //                    } else if variableValues[opSymbol] != nil {
                    } else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    
    
    
    private func evaluate(ops: [Op]) -> (result:Double?, remainingOps: [Op])
    {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand,remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand =  operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1,operand2),op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                
                return (variableValues[symbol],remainingOps)
                
            case .Constant(let operand,_):
                return (operand,remainingOps)
            }
            
            
        }
        
        return (nil,ops)
    }
    
    func evaluateAndReportErrors() -> CalculatorBrainEvaluationResult {
        if let evaluationResult = evaluate() {
            if evaluationResult.isInfinite {
                return CalculatorBrainEvaluationResult.Failure("Infinite value")
            } else if evaluationResult.isNaN {
                return CalculatorBrainEvaluationResult.Failure("Not a number")
            } else {
                return CalculatorBrainEvaluationResult.Success(evaluationResult)
            }
        } else {
            if let returnError = error {
                // We consumed the error, now set error back to nil
                error = nil
                return CalculatorBrainEvaluationResult.Failure(returnError)
            } else {
                return CalculatorBrainEvaluationResult.Failure("Error")
            }
        }
    }
    
    func evaluate() -> Double? {
        let ( result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over)")
        return result
    }
    
    func pushOperand(operand:Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func printOps() -> NSString{
        return "\(opStack)"
        
    }
}