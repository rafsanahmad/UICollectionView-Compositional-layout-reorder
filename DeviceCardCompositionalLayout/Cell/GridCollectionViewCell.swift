//
//  GridCollectionViewCell.swift
//  DeviceCardCompositionalLayout
//
//  Created by Rafsan Ahmad on 22/2/23.
//

import Foundation
import UIKit

final class GridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var cellData: CardType? {
        didSet {
            guard let cellData = cellData else {
                return
            }
            title.text = String(cellData.value)
            switch cellData.style {
            case .complex:
                subtitle.text = "Complex"
            case .basic:
                subtitle.text = "Basic"
            }
        }
    }
    
    static var loadNib: UINib {
        UINib.init(nibName: reuseID, bundle: nil)
    }
    
    static var reuseID: String {
        return String(describing: GridCollectionViewCell.classForCoder())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = .tertiarySystemBackground
        contentView.layer.cornerRadius = 16
    }
}
