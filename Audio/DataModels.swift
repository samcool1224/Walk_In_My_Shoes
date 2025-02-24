//
//  DataModels.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/23/25.
//
import Foundation
@available(iOS 14, *)

struct Stage: Identifiable {
    let id = UUID()
    let narrative: String
    let impairment: ImpairmentType
    let challengeQuestion: String
    let options: [String]
    let correctAnswer: String
}

struct AudioChapter {
    let title: String
    let narrative: String
    let warning: String
    let simulationType: SimulationType
    enum SimulationType {
        case normal
        case tinnitus
        case suddenLoss
        case presbycusis
    }
    
}
