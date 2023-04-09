//
//  DeviceCardGroupProvider.swift
//  DeviceCardCompositionalLayout
//
//  Created by Rafsan Ahmad on 22/2/23.
//

import Foundation
import UIKit

final class DeviceCardGroupProvider: DynamicLayoutGroupProvider {

    private lazy var basicGroupSize = configureBasicGroupSize()
    private lazy var basicOrphanGroupSize = configureBasicOrphanGroupSize()
    private lazy var complexGroupSize = configureComplexGroupSize()

    private lazy var compactWidthLayoutItem = configureBasicWidthLayoutItem()
    private lazy var fullWidthLayoutItem = configureComplexWidthLayoutItem()

    private lazy var basicGroup = configureBasicGroup()
    private lazy var basicOrphanGroup = configureBasicOrphanGroup()
    private lazy var complexGroup = configureComplexGroup()
}

extension DeviceCardGroupProvider {

    func deriveLayoutGroup(
        basedOnPreviousStyle previousStyle: CardType.Style?,
        currentStyle: CardType.Style,
        nextStyle: CardType.Style?
    ) -> NSCollectionLayoutGroup? {

        // Determining how to layout a cell requires knowing the
        // - previous cell's style (may be `nil`; first cell)
        // - current cell's style (non-`nil`)
        // - next cell's style (may be `nil`; last cell)

        // Special case if we are at the end.
        guard let nextStyle = nextStyle else {
            switch currentStyle {
            case .basic:
                return basicOrphanGroup
            case .complex:
                return complexGroup
            }
        }
        
        switch (previousStyle, currentStyle, nextStyle) {
        case (.none, .basic, .basic):
            return basicGroup
        case (.none, .basic, .complex):
            return basicOrphanGroup
        case (.basic, .basic, .basic):
            return nil
        case (.basic, .basic, .complex):
            return nil
        case (.complex, .basic, .basic):
            return basicGroup
        case (.complex, .basic, .complex):
            return basicOrphanGroup
        case (_, .complex, _):
            return complexGroup
        }
    }
}

extension DeviceCardGroupProvider {

    private func configureBasicGroup() -> NSCollectionLayoutGroup {
        let basicGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: basicGroupSize,
            subitem: compactWidthLayoutItem,
            count: 2
        )
        basicGroup.interItemSpacing = .fixed(16)

        return basicGroup
    }

    private func configureBasicOrphanGroup() -> NSCollectionLayoutGroup {
        return NSCollectionLayoutGroup.horizontal(
            layoutSize: basicOrphanGroupSize,
            subitem: fullWidthLayoutItem,
            count: 1
        )
    }

    private func configureComplexGroup() -> NSCollectionLayoutGroup {
        return NSCollectionLayoutGroup.horizontal(
            layoutSize: complexGroupSize,
            subitem: fullWidthLayoutItem,
            count: 1
        )
    }
}

extension DeviceCardGroupProvider {

    private func configureBasicWidthLayoutItem() -> NSCollectionLayoutItem {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )

        return NSCollectionLayoutItem(layoutSize: layoutSize)
    }

    private func configureComplexWidthLayoutItem() -> NSCollectionLayoutItem {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        return NSCollectionLayoutItem(layoutSize: layoutSize)
    }
}

extension DeviceCardGroupProvider {
    private func configureBasicGroupSize() -> NSCollectionLayoutSize {
        return NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.5)
        )
    }

    private func configureBasicOrphanGroupSize() -> NSCollectionLayoutSize {
        return NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5)
        )
    }

    private func configureComplexGroupSize() -> NSCollectionLayoutSize {
        return NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.5)
        )
    }
}

