//
//  PHDiff.swift
//  PHDiff
//
//  Created by Andre Alves on 10/13/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import Foundation

/// Based on Paul Heckel's paper: A technique for isolating differences between files (1978).
public struct PHDiff {
    /// Creates steps (Inserts, Deletes, Moves and Updates) for batch operations.
    /// Can be used for UITableView, UICollectionView batch updates.
    /// Complexity: O(n+m) where n is fromArray.count and m is toArray.count.
    public static func diff<T: Diffable>(fromArray: [T], toArray: [T]) -> DiffResult<T> {
        // Creates and setups one context.
        let context = DiffContext<T>(fromArray: fromArray, toArray: toArray)

        var inserts: [DiffStep<T>] = []
        var deletes: [DiffStep<T>] = []
        var moves: [DiffStep<T>] = []
        var updates: [DiffStep<T>] = []

        var deleteOffsets = Array(repeating: 0, count: fromArray.count)
        var runningOffset = 0

        // Find deletions and incremement offset for each delete
        for (j, ref) in context.OA.enumerated() {
            deleteOffsets[j] = runningOffset
            if ref.symbol != nil {
                deletes.append(.delete(value: context.fromArray[j], index: j))
                runningOffset += 1
            }
        }

        runningOffset = 0

        // Find inserts, moves and updates
        for (i, ref) in context.NA.enumerated() {
            if let j = ref.index {
                // Check if this object has changed
                if context.toArray[i] != context.fromArray[j] {
                    updates.append(.update(value: context.toArray[i], index: i))
                }

                // Checks for the current offset, if matches means that this move is not needed
                let deleteOffset = deleteOffsets[j]
                if (j - deleteOffset + runningOffset) != i {
                    moves.append(.move(value: context.toArray[i], fromIndex: j, toIndex: i))
                }
            } else {
                inserts.append(.insert(value: context.toArray[i], index: i))
                runningOffset += 1
            }
        }

        return DiffResult(deletes: deletes, inserts: inserts, moves: moves, updates: updates)
    }
}
