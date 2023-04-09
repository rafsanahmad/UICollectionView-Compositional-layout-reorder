//
//  CardType.swift
//  DeviceCardCompositionalLayout
//
//  Created by Rafsan Ahmad on 22/2/23.
//

import Foundation

struct CardType: Hashable {
    enum Style {
        case complex
        case basic
    }

    let value: Int
    let style: Style
    private let identifier = UUID()
}


extension ViewController {
    func makeRandomDeviceCards() -> [CardType] {
        let basicCards = (0..<Int.random(in: 10..<20)).map {
            CardType(value: $0, style: .basic)
        }
        
        let complexCards = (100..<Int.random(in: 110..<120)).map {
            CardType(value: $0, style: .complex)
        }
        
        return (basicCards + complexCards).shuffled()
    }
}
