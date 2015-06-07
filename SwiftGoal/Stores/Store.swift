//
//  Store.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Argo

class Store: NSObject {

    private let baseURL = NSURL(string: "http://localhost:3000/api/v1/matches")!

    // MARK: - Matches

    func fetchMatches() -> SignalProducer<[Match], NoError> {
        let request = NSURLRequest(URL: baseURL)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            |> map { data, response in
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
                if let j: AnyObject = json, matches: [Match] = decode(j) {
                    return matches
                } else {
                    return []
                }
            }
            |> catch { _ in SignalProducer<[Match], NoError>.empty }
    }
}
