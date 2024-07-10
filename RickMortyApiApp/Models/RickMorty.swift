//
//  RickMorty.swift
//  RickMortyApiApp
//
//  Created by Sergey Zakurakin on 11/05/2024.
//

import Foundation

struct RickMorty: Codable {
    let info: Info
    let results: [CharacterResult]
}

struct Info: Codable {
    let next: String
}

struct CharacterResult: Codable {
    let name: String
    let image: String
}
