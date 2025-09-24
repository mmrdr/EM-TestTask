//
//  Fonts.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

enum Fonts {
    static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let trashTitleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let descriptionFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let trashDescriptionFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    static let dateFont = descriptionFont // для консистентности
    static let trashDateFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let headerFont = UIFont.systemFont(ofSize: 22, weight: .bold)
}
