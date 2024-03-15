//
//  AltushkaModel.swift
//  Alternative
//
//  Created by Евгений Мазурок on 13.03.2024.
//

import Foundation

struct Altushka: Hashable{
    var id: String = UUID().uuidString
    var name: String
    var tags: [String]
    var photo: String
    var isFree: Bool
}
