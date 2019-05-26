//
//  SectionedNotificationTokenBlock.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/26/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

/// Used to group change notifications that occur within the same table view.
class SectionedNotificationTokenBlock {
    struct Changes {
        var deletions = [IndexPath]()
        var insertions = [IndexPath]()
        var modifications = [IndexPath]()
    }

    private var queuedChanges = Changes()
    /// Called with all queued changes.
    private var updateBlock: (Changes) -> Void
    /// Groups change notifications that occur within the same table view.
    ///
    /// - Parameter updateBlock: The block to be called whenever an update occurs.
    init(_ updateBlock: @escaping (Changes) -> Void) {
        self.updateBlock = updateBlock
    }

    /// Returns a closure you can provide as the handler for `observe`.
    ///
    /// - Parameter section: The section of the content in your table view.
    func block<CollectionType>(forSection section: Int, initialBlock: (() -> Void)? = nil, errorBlock: ((Error) -> Void)? = nil) -> ((RealmCollectionChange<CollectionType>) -> Void) {
        return { change in
            switch change {
            case let .error(error):
                errorBlock?(error)
            case let .update(_, deletions, insertions, modifications):
                self.queuedChanges.deletions.append(contentsOf: deletions.map { IndexPath(row: $0, section: section) })
                self.queuedChanges.insertions.append(contentsOf: insertions.map { IndexPath(row: $0, section: section) })
                self.queuedChanges.modifications.append(contentsOf: modifications.map { IndexPath(row: $0, section: section) })
                OperationQueue.current?.underlyingQueue?.async(execute: self.drainQueue)
            case .initial:
                initialBlock?()
            }
        }
    }

    /// Calls the sectioned notification token block with all changes.
    private func drainQueue() {
        guard queuedChanges.deletions.count > 0 || queuedChanges.insertions.count > 0 || queuedChanges.modifications.count > 0 else { return }
        updateBlock(queuedChanges)
        queuedChanges = Changes()
    }
}
