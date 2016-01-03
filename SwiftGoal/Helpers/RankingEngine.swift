//
//  RankingEngine.swift
//  SwiftGoal
//
//  Created by Martin Richter on 02/01/16.
//  Copyright © 2016 Martin Richter. All rights reserved.
//

class RankingEngine {
    private let pointsForWin = 3
    private let pointsForTie = 1
    private let pointsForLoss = 0

    private enum Side {
        case Home
        case Away
    }

    func rankingsForPlayers(players: [Player], fromMatches matches: [Match]) -> [Ranking] {
        if players.isEmpty {
            return []
        }

        if matches.isEmpty {
            return players.map { player in
                return Ranking(player: player, rating: 0)
            }
        }

        let rankings = players.map { (player: Player) -> Ranking in
            let homeMatches = matches.filter { $0.homePlayers.contains(player) }
            let awayMatches = matches.filter { $0.awayPlayers.contains(player) }

            let homePoints = homeMatches.reduce(0, combine: { sum, match in
                return sum + pointsFromMatch(match, forSide: .Home)
            })

            let awayPoints = awayMatches.reduce(0, combine: { sum, match in
                return sum + pointsFromMatch(match, forSide: .Away)
            })

            let maxHomePoints = homeMatches.count * pointsForWin
            let maxAwayPoints = awayMatches.count * pointsForWin
            let rating = 10 * Float(homePoints + awayPoints) / Float(maxHomePoints + maxAwayPoints)

            return Ranking(player: player, rating: rating)
        }

        return rankings.sort { lhs, rhs in lhs.rating > rhs.rating }
    }

    // MARK: Private Helpers

    private func pointsFromMatch(match: Match, forSide side: Side) -> Int {
        if match.homeGoals > match.awayGoals {
            return side == .Home ? pointsForWin : pointsForLoss
        } else if match.awayGoals > match.homeGoals {
            return side == .Home ? pointsForLoss : pointsForWin
        } else {
            return pointsForTie
        }
    }
}
