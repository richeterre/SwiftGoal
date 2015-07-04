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

struct MatchParameters {
    let homePlayers: Set<Player>
    let awayPlayers: Set<Player>
    let homeGoals: Int
    let awayGoals: Int
}

enum RequestMethod {
    case GET
    case POST
    case PUT
    case DELETE
}

class Store: NSObject {

    private static let baseURL = NSURL(string: "http://localhost:3000/api/v1/")!
    private static let matchesURL = NSURL(string: "matches", relativeToURL: baseURL)!
    private static let playersURL = NSURL(string: "players", relativeToURL: baseURL)!

    // MARK: - Matches

    func fetchMatches() -> SignalProducer<[Match], NoError> {
        let request = mutableRequestWithURL(Store.matchesURL, method: .GET)
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

    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NoError> {

        let request = mutableRequestWithURL(Store.matchesURL, method: .POST)
        request.HTTPBody = httpBodyForMatchParameters(parameters)

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

    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NoError> {

        let request = mutableRequestWithURL(urlForMatch(match), method: .PUT)
        request.HTTPBody = httpBodyForMatchParameters(parameters)

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

    func deleteMatch(match: Match) -> SignalProducer<Bool, NoError> {
        let request = mutableRequestWithURL(urlForMatch(match), method: .DELETE)

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

    private func httpBodyForMatchParameters(parameters: MatchParameters) -> NSData? {
        let jsonObject = [
            "home_player_ids": Array(parameters.homePlayers).map { $0.identifier },
            "away_player_ids": Array(parameters.awayPlayers).map { $0.identifier },
            "home_goals": parameters.homeGoals,
            "away_goals": parameters.awayGoals
        ]

        return NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: nil)
    }

    private func urlForMatch(match: Match) -> NSURL {
        return Store.matchesURL.URLByAppendingPathComponent(match.identifier)
    }

    private func mutableRequestWithURL(url: NSURL, method: RequestMethod) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)

        switch method {
            case .GET:
                request.HTTPMethod = "GET"
            case .POST:
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .PUT:
                request.HTTPMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .DELETE:
                request.HTTPMethod = "DELETE"
        }

        return request
    }
}
