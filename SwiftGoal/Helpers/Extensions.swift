//
//  Extensions.swift
//  SwiftGoal
//
//  Created by Martin Richter on 23/06/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa
import Result

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

extension UIViewController {
    func isActive() -> SignalProducer<Bool, NoError> {

        // Track whether view is visible

        let viewWillAppear = rac_signalForSelector(#selector(viewWillAppear(_:))).toSignalProducer()
        let viewWillDisappear = rac_signalForSelector(#selector(viewWillDisappear(_:))).toSignalProducer()

        let viewIsVisible = SignalProducer(values: [
            viewWillAppear.map { _ in true },
            viewWillDisappear.map { _ in false }
        ]).flatten(.Merge)

        // Track whether app is in foreground

        let notificationCenter = NSNotificationCenter.defaultCenter()

        let didBecomeActive = notificationCenter
            .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
            .toSignalProducer()

        let willBecomeInactive = notificationCenter
            .rac_addObserverForName(UIApplicationWillResignActiveNotification, object: nil)
            .toSignalProducer()

        let appIsActive = SignalProducer(values: [
            SignalProducer(value: true), // Account for app being initially active without notification
            didBecomeActive.map { _ in true },
            willBecomeInactive.map { _ in false }
        ]).flatten(.Merge)

        // View controller is active iff both are true:

        return combineLatest(viewIsVisible, appIsActive)
            .map { $0 && $1 }
            .flatMapError { _ in SignalProducer.empty }
    }
}
