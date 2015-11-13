//
//  Store.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import Argo
import ReactiveCocoa

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

    private let baseURL: NSURL
    private let matchesURL: NSURL
    private let playersURL: NSURL
    private let rankingsURL: NSURL

    // MARK: Lifecycle

    init(baseURL: NSURL) {
        self.baseURL = baseURL
        self.matchesURL = NSURL(string: "matches", relativeToURL: baseURL)!
        self.playersURL = NSURL(string: "players", relativeToURL: baseURL)!
        self.rankingsURL = NSURL(string: "rankings", relativeToURL: baseURL)!
    }

    // MARK: - Matches

    func fetchMatches(tries: Int = 1) -> SignalProducer<[Match], NSError> {
       
        let request = mutableRequestWithURL(matchesURL, method: .GET)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .retry(tries)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    matches: [Match] = decode(json) {
                    return matches
                } else {
                    return []
                }
            }
    }

    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError> {

        let request = mutableRequestWithURL(matchesURL, method: .POST)
        request.HTTPBody = httpBodyForMatchParameters(parameters)

        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 201
                } else {
                    return false
                }
            }
    }

    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError> {

        let request = mutableRequestWithURL(urlForMatch(match), method: .PUT)
        request.HTTPBody = httpBodyForMatchParameters(parameters)

        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 200
                } else {
                    return false
                }
            }
    }

    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError> {
        let request = mutableRequestWithURL(urlForMatch(match), method: .DELETE)

        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 200
                } else {
                    return false
                }
            }
    }

    // MARK: Players

    func fetchPlayers() -> SignalProducer<[Player], NSError> {
        let request = NSURLRequest(URL: playersURL)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    players: [Player] = decode(json) {
                    return players
                } else {
                    return []
                }
            }
    }

    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError> {
        let request = mutableRequestWithURL(playersURL, method: .POST)
        request.HTTPBody = httpBodyForPlayerName(name)

        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 201
                } else {
                    return false
                }
            }
    }

    // MARK: Rankings

    func fetchRankings() -> SignalProducer<[Ranking], NSError> {
        let request = NSURLRequest(URL: rankingsURL)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    rankings: [Ranking] = decode(json) {
                    return rankings
                } else {
                    return []
                }
        }
    }

    // MARK: Private Helpers

    private func httpBodyForMatchParameters(parameters: MatchParameters) -> NSData? {
        let jsonObject = [
            "home_player_ids": Array(parameters.homePlayers).map { $0.identifier },
            "away_player_ids": Array(parameters.awayPlayers).map { $0.identifier },
            "home_goals": parameters.homeGoals,
            "away_goals": parameters.awayGoals
        ]

        return try? NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
    }

    private func httpBodyForPlayerName(name: String) -> NSData? {
        let jsonObject = [
            "name": name
        ]

        return try? NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
    }

    private func urlForMatch(match: Match) -> NSURL {
        return matchesURL.URLByAppendingPathComponent(match.identifier)
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
