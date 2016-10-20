//
//  DiffResult.swift
//  PHDiff
//
//  Created by Andre Alves on 10/19/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import Foundation

public final class DiffResult<T: Diffable> {
    public let deletes: [DiffStep<T>]
    public let inserts: [DiffStep<T>]
    public let moves: [DiffStep<T>]
    public let updates: [DiffStep<T>]

    public convenience init(steps: [DiffStep<T>]) {
        var deletes: [DiffStep<T>] = []
        var inserts: [DiffStep<T>] = []
        var moves: [DiffStep<T>] = []
        var updates: [DiffStep<T>] = []

        steps.forEach { step in
            switch step {
            case .delete: deletes.append(step)
            case .insert: inserts.append(step)
            case .move: moves.append(step)
            case .update: updates.append(step)
            }
        }

        self.init(deletes: deletes, inserts: inserts, moves: moves, updates: updates)
    }

    public init(deletes: [DiffStep<T>], inserts: [DiffStep<T>], moves: [DiffStep<T>], updates: [DiffStep<T>]) {
        self.deletes = deletes
        self.inserts = inserts
        self.moves = moves
        self.updates = updates
    }

    public var stepsCount: Int {
        return deletes.count + inserts.count + moves.count + updates.count
    }

    public var steps: [DiffStep<T>] {
        return deletes + inserts + moves + updates
    }

    public var applicableSteps: [DiffStep<T>] {
        let converted = movesConvertedToDeletesAndInserts()
        let deletes = converted.deletes.sorted { $0.index > $1.index }
        let inserts = converted.inserts.sorted { $0.index < $1.index }
        return deletes + inserts + converted.moves + converted.updates
    }

    public func convertedToDeletesAndInserts() -> DiffResult<T> {
        return movesConvertedToDeletesAndInserts().updatesConvertedToDeletesAndInserts()
    }

    public func movesConvertedToDeletesAndInserts() -> DiffResult<T> {
        var convertedInserts: [DiffStep<T>] = []
        var convertedDeletes: [DiffStep<T>] = []

        moves.forEach { step in
            switch step {
            case let .move(value, fromIndex, toIndex):
                convertedDeletes.append(.delete(value: value, index: fromIndex))
                convertedInserts.append(.insert(value: value, index: toIndex))
            default: break
            }
        }

        return DiffResult(deletes: deletes+convertedDeletes,
                          inserts: inserts+convertedInserts,
                          moves: [],
                          updates: updates)
    }

    public func updatesConvertedToDeletesAndInserts() -> DiffResult<T> {
        var convertedInserts: [DiffStep<T>] = []
        var convertedDeletes: [DiffStep<T>] = []

        updates.forEach { step in
            switch step {
            case let .update(value, index):
                convertedDeletes.append(.delete(value: value, index: index))
                convertedInserts.append(.insert(value: value, index: index))
            default: break
            }
        }

        return DiffResult(deletes: deletes+convertedDeletes,
                          inserts: inserts+convertedInserts,
                          moves: moves,
                          updates: [])
    }
}
