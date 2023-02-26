//
//  ViewController.swift
//  DeviceCardCompositionalLayout
//
//  Created by Rafsan Ahmad on 22/2/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    private lazy var dataSource = configureDataSource()
    private lazy var collectionView = makeCollectionView()
    
    private lazy var layoutGroupProvider = makeDynamicLayoutGroupProvider()
    
    private var deviceCards: [CardType] {
        get {
            return dataSource.snapshot().itemIdentifiers
        }
        
        set {
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            
            if newValue.count > 0 {
                snapshot.appendSections([.main])
                snapshot.appendItems(newValue, toSection: .main)
            }
            
            dataSource.apply(snapshot)
        }
    }
    
    // Represents a snapshot of how the items/ cells will be placed when
    // the reorder drag operation completes.
    private var proposedDragItems: [CardType]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Card layout reorder"
        deviceCards = makeRandomDeviceCards()
        enableReorderSupport(on: dataSource)
        add(collectionView, to: view)
        configure(collectionView)
    }
}

// MARK: UICollectionView Set Up

extension ViewController {
    
    private func makeCollectionView() -> UICollectionView {
        return UICollectionView(frame: view.frame, collectionViewLayout: makeDynamicCollectionViewLayout())
    }
    
    private func add(_ collectionView: UICollectionView, to view: UIView) {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        collectionView.layoutIfNeeded()
    }
    
    private func configure(_ collectionView: UICollectionView) {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
}

// MARK: UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate { }

// MARK: UICollectionViewDragDelegate

extension ViewController: UICollectionViewDragDelegate {
    
    func collectionView(
        _: UICollectionView,
        itemsForBeginning _: UIDragSession,
        at _: IndexPath
    ) -> [UIDragItem] {
        proposedDragItems = nil
        return []
    }
    
    func collectionView(
        _: UICollectionView,
        targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
        atCurrentIndexPath currentIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        let currentItem = dataSource.itemIdentifier(for: currentIndexPath)
        let proposedItem = dataSource.itemIdentifier(for: proposedIndexPath)
        
        guard currentItem != proposedItem else {
            return proposedIndexPath
        }
        
        let from = originalIndexPath.item
        let to = proposedIndexPath.item
        
        let fromOffsets = IndexSet(integer: from)
        let toOffset = to > from ? to + 1 : to
        
        
        // The mutated snapshot is not applied to the data source. Instead
        // the snapshot is stored in the `proposedDragItems`. The `proposedDragItems`
        // is used to drive dynamic changes to the compositional layout during a drag/ reorder.
        var proposedDragItems = dataSource.snapshot().itemIdentifiers
        
        proposedDragItems.move(fromOffsets: fromOffsets, toOffset: toOffset)
        self.proposedDragItems = proposedDragItems
        
        return proposedIndexPath
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        dragPreviewParametersForItemAt indexPath: IndexPath
    ) -> UIDragPreviewParameters? {
        return previewParameters(forItemAt: indexPath, collectionView: collectionView)
    }
}

// MARK: UICollectionViewDropDelegate

extension ViewController: UICollectionViewDropDelegate {
    
    func collectionView(_: UICollectionView, performDropWith _: UICollectionViewDropCoordinator) {
        // Note: This is a required `UICollectionViewDropDelegate` method.
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        dropPreviewParametersForItemAt indexPath: IndexPath
    ) -> UIDragPreviewParameters? {
        return previewParameters(forItemAt: indexPath, collectionView: collectionView)
    }
}


// MARK: Compositional Layout Set Up

extension ViewController {
    
    private func makeDynamicCollectionViewLayout() -> UICollectionViewLayout {
        // This method is called a lot during dragging.
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .readableContent
        
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] _, _ in
            guard let self = self else {
                return nil
            }
            
            // This is the where the we get the collection view cells to move
            // around as the user drags a lifted cell.
            let items = self.proposedDragItems ?? self.dataSource.snapshot().itemIdentifiers
            let styles = items.map { $0.style }
            if styles.isEmpty {
                return nil
            }
            return self.makeSection(for: styles)
        }, configuration: configuration)
    }
    
    private func makeSection(
        for styles: [CardType.Style]
    ) -> NSCollectionLayoutSection {
        
        var groups: [NSCollectionLayoutItem] = []
        
        var previousStyle: CardType.Style? = nil
        for index in 0..<styles.count {
            let currentStyle = styles[index]
            let nextStyle = (index == styles.count - 1) ? nil: styles[index + 1]
            
            let proposedLayoutGroup = layoutGroupProvider.deriveLayoutGroup(
                basedOnPreviousStyle: previousStyle,
                currentStyle: currentStyle,
                nextStyle: nextStyle
            )
            
            if let layoutGroup = proposedLayoutGroup {
                groups.append(layoutGroup)
                previousStyle = currentStyle
            } else {
                previousStyle = nil
            }
        }
        
        return makeSection(forGroup: makeOuterGroup(forSubitems: groups))
    }
    
    private func makeSection(
        forGroup group: NSCollectionLayoutGroup
    ) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
        return section
    }
    
    private func makeOuterGroup(
        forSubitems subitems: [NSCollectionLayoutItem]
    ) -> NSCollectionLayoutGroup {
        let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let outerGroup = NSCollectionLayoutGroup.vertical(layoutSize: outerGroupSize, subitems: subitems)
        outerGroup.interItemSpacing = .fixed(16)
        
        return outerGroup
    }
    
    private func makeDynamicLayoutGroupProvider() -> DynamicLayoutGroupProvider {
        return DeviceCardGroupProvider()
    }
}

// MARK: Diffable Data Source Set Up

extension ViewController {
    private func configureDataSource() -> UICollectionViewDiffableDataSource<Section, CardType> {
        let cellRegistration = makeCellRegistration()
        return UICollectionViewDiffableDataSource<Section, CardType>(collectionView: collectionView) { (
            collectionView, indexPath, identifier) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<GridCollectionViewCell, CardType> {
        return UICollectionView.CellRegistration<GridCollectionViewCell, CardType>(cellNib: GridCollectionViewCell.loadNib) {
            cell, indexPath, model in
            cell.title.text = String(model.value)
            switch model.style {
            case .complex:
                cell.subtitle.text = "Complex"
            case .basic:
                cell.subtitle.text = "Basic"
            }
        }
    }
}

// MARK: Diffable Data Source Reorder Support

extension ViewController {
    private func enableReorderSupport(on dataSource: UICollectionViewDiffableDataSource<Section, CardType>) {
        dataSource.reorderingHandlers.canReorderItem = { _ in
            // All items are eligible for reordering.
            return true
        }
        
        dataSource.reorderingHandlers.didReorder = { [weak self] value in
            // When the drag is finished, the `proposedDragItems` are cleared.
            // New items are set when the user starts dragging again.
            self?.proposedDragItems = nil
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

// MARK: Private Helpers To Create `UIPreviewParameters` (lift, drag, and drop)

extension ViewController {
    private func previewParameters(
        forItemAt indexPath: IndexPath,
        collectionView: UICollectionView
    ) -> UIDragPreviewParameters? {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        return makePreviewParameters(forCell: cell)
    }
    
    private func makePreviewParameters<P: UIPreviewParameters>(forCell cell: UICollectionViewCell) -> P {
        let previewParameters = P()
        previewParameters.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius)
        previewParameters.visiblePath = previewParameters.shadowPath
        previewParameters.backgroundColor = .clear
        return previewParameters
    }
}

extension ViewController {
    private enum Section: Hashable {
        case main
    }
}

