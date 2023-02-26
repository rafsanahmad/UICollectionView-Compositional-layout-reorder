//
//  DynamicLayoutGroupProvider.swift
//  DeviceCardCompositionalLayout
//
//  Created by Rafsan Ahmad on 22/2/23.
//

import UIKit

/// This protocol declares an API for deriving a `NSCollectionLayoutGroup` based on
/// the previous model style (may be `nil`), the current style (non-`nil`) and the next style (may be `nil`).
protocol DynamicLayoutGroupProvider {

    func deriveLayoutGroup(
        basedOnPreviousStyle previousStyle: CardType.Style?,
        currentStyle: CardType.Style,
        nextStyle: CardType.Style?
    ) -> NSCollectionLayoutGroup?
}
