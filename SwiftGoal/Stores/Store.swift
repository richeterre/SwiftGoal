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

    private static let baseURL = NSURL(string: "http://localhost:3000/api/v1/")!
    private static let matchesURL = NSURL(string: "matches", relativeToURL: baseURL)!
    private static let playersURL = NSURL(string: "players", relativeToURL: baseURL)!

    // MARK: - Matches

    func fetchMatches() -> SignalProducer<[Match], NoError> {
        let request = NSURLRequest(URL: Store.matchesURL)
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

    func createMatch(#homePlayers: Set<Player>, awayPlayers: Set<Player>, homeGoals: Int, awayGoals: Int) -> SignalProducer<Bool, NoError> {

        let request = NSMutableURLRequest(URL: Store.matchesURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = httpBodyForParameters([
            "home_player_ids": Array(homePlayers).map { $0.identifier },
            "away_player_ids": Array(awayPlayers).map { $0.identifier },
            "home_goals": homeGoals,
            "away_goals": awayGoals
        ])

        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            |> map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 201
                } else {
                    return false
                }
            }
            |> catch { _ in
                return SignalProducer<Bool, NoError>(value: false)
            }
    }

    func deleteMatch(match: Match) -> SignalProducer<Bool, NoError> {
        let request = NSMutableURLRequest(URL: Store.matchesURL.URLByAppendingPathComponent(match.identifier))
        request.HTTPMethod = "DELETE"

        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            |> map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 200
                } else {
                    return false
                }
            }
            |> catch { _ in
                return SignalProducer<Bool, NoError>(value: false)
            }
    }

    // MARK: Players

    func fetchPlayers() -> SignalProducer<[Player], NoError> {
        let request = NSURLRequest(URL: Store.playersURL)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            |> map { data, response in
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
                if let j: AnyObject = json, players: [Player] = decode(j) {
                    return players
                } else {
                    return []
                }
            }
            |> catch { _ in SignalProducer<[Player], NoError>.empty }
    }

    // MARK: Internal Helpers

    private func httpBodyForParameters(parameters: [String: AnyObject]) -> NSData? {
        return NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: nil)
    }
}
