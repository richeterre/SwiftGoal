//
//  LocalStore.swift
//  SwiftGoal
//
//  Created by Martin Richter on 31/12/15.
//  Copyright © 2015 Martin Richter. All rights reserved.
//

import Argo
import ReactiveCocoa

class LocalStore: StoreType {

    private var matches = [Match]()
    private var players = [Player]()

    private let rankingEngine = RankingEngine()

    private let matchesKey = "matches"
    private let playersKey = "players"
    private let archiveFileName = "LocalStore"

    // MARK: Matches

    func fetchMatches() -> SignalProducer<[Match], NSError> {
        return SignalProducer(value: matches)
    }

    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        let identifier = randomIdentifier()
        let match = matchFromParameters(parameters, withIdentifier: identifier)
        matches.append(match)

        return SignalProducer(value: true)
    }

    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        if let oldMatchIndex = matches.indexOf(match) {
            let newMatch = matchFromParameters(parameters, withIdentifier: match.identifier)
            matches.removeAtIndex(oldMatchIndex)
            matches.insert(newMatch, atIndex: oldMatchIndex)
            return SignalProducer(value: true)
        } else {
            return SignalProducer(value: false)
        }
    }

    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError> {
        if let index = matches.indexOf(match) {
            matches.removeAtIndex(index)
            return SignalProducer(value: true)
        } else {
            return SignalProducer(value: false)
        }
    }

    // MARK: Players

    func fetchPlayers() -> SignalProducer<[Player], NSError> {
        return SignalProducer(value: players)
    }

    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError> {
        let player = Player(identifier: randomIdentifier(), name: name)

        // Keep alphabetical order when inserting player
        let alphabeticalIndex = players.indexOf { existingPlayer in
            existingPlayer.name > player.name
        }
        if let index = alphabeticalIndex {
            players.insert(player, atIndex: index)
        } else {
            players.append(player)
        }

        return SignalProducer(value: true)
    }

    // MARK: Rankings

    func fetchRankings() -> SignalProducer<[Ranking], NSError> {
      let rankings = rankingEngine.rankingsForPlayers(players, fromMatches: matches)
      return SignalProducer(value: rankings)
    }

    // MARK: Persistence

    func archiveToDisk() {
        let matchesDict = matches.map { $0.encode() }
        let playersDict = players.map { $0.encode() }

        let dataDict = [matchesKey: matchesDict, playersKey: playersDict]

        if let filePath = persistentFilePath() {
            NSKeyedArchiver.archiveRootObject(dataDict, toFile: filePath)
        }
    }

    func unarchiveFromDisk() {
        if let
            path = persistentFilePath(),
            dataDict = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [String: AnyObject],
            matchesDict = dataDict[matchesKey],
            playersDict = dataDict[playersKey],
            matches: [Match] = decode(matchesDict),
            players: [Player] = decode(playersDict)
        {
            self.matches = matches
            self.players = players
        }
    }

    // MARK: Private Helpers

    private func randomIdentifier() -> String {
        return NSUUID().UUIDString
    }

    private func matchFromParameters(parameters: MatchParameters, withIdentifier identifier: String) -> Match {
        let sortByName: (Player, Player) -> Bool = { players in
            players.0.name < players.1.name
        }

        return Match(
            identifier: identifier,
            homePlayers: parameters.homePlayers.sort(sortByName),
            awayPlayers: parameters.awayPlayers.sort(sortByName),
            homeGoals: parameters.homeGoals,
            awayGoals: parameters.awayGoals
        )
    }

    private func persistentFilePath() -> String? {
        let basePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as NSString?
        return basePath?.stringByAppendingPathComponent(archiveFileName)
    }
}
