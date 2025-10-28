//
//  Pokemon.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import Foundation

struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Codable, Equatable {
    let name: String
    let url: String
}

struct PokemonDetail: Codable {
    let id: Int
    let name: String
    let abilities: [AbilitySlot]
    let sprites: SpriteInfo
}

struct AbilitySlot: Codable {
    let ability: Ability
    let isHidden: Bool
    let slot: Int
    
    enum CodingKeys: String, CodingKey {
        case ability
        case isHidden = "is_hidden"
        case slot
    }
}

struct Ability: Codable {
    let name: String
    let url: String
}

struct SpriteInfo: Codable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
