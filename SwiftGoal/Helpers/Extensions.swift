//
//  Extensions.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension Array {
    func difference<T: Equatable>(otherArray: [T]) -> [T] {
        var result = [T]()

        for e in self {
            if let element = e as? T {
                if !otherArray.contains(element) {
                    result.append(element)
                }
            }
        }

        return result
    }

    func intersection<T: Equatable>(otherArray: [T]) -> [T] {
        var result = [T]()

        for e in self {
            if let element = e as? T {
                if otherArray.contains(element) {
                    result.append(element)
                }
            }
        }

        return result
    }
}

extension UIStepper {
    func signalProducer() -> SignalProducer<Int, NoError> {
        return self.rac_newValueChannelWithNilValue(0).toSignalProducer()
            .map { $0 as! Int }
            .flatMapError { _ in return SignalProducer<Int, NoError>.empty }
    }
}

extension UITextField {
    func signalProducer() -> SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer()
            .map { $0 as! String }
            .flatMapError { _ in return SignalProducer<String, NoError>.empty }
    }
}
