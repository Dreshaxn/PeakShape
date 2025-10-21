//
//  FatSecretResponse.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import Foundation

// MARK: - FatSecret Barcode API Response

public struct FatSecretBarcodeResponse: Codable, Hashable {
    public let food: FatSecretFood?
    
    public init(food: FatSecretFood?) {
        self.food = food
    }
}

// MARK: - FatSecret Search API Response

public struct FatSecretSearchResponse: Codable, Hashable {
    public let foods_search: FatSecretFoodsSearch?
    
    public init(foods_search: FatSecretFoodsSearch?) {
        self.foods_search = foods_search
    }
}

// MARK: - Search Metadata

public struct FatSecretFoodsSearch: Codable, Hashable {
    public let max_results: String?
    public let total_results: String?
    public let page_number: String?
    public let results: FatSecretResults?
    
    public init(max_results: String?, total_results: String?, page_number: String?, results: FatSecretResults?) {
        self.max_results = max_results
        self.total_results = total_results
        self.page_number = page_number
        self.results = results
    }
}

// MARK: - Search Results Container

public struct FatSecretResults: Codable, Hashable {
    public let food: [FatSecretFood]
    
    public init(food: [FatSecretFood]) {
        self.food = food
    }
}

// MARK: - Food Item

public struct FatSecretFood: Codable, Identifiable, Hashable {
    public var id: String { food_id }

    public let food_id: String
    public let food_name: String
    public let food_type: String?
    public let food_url: String?
    public let brand_name: String?
    public let servings: FatSecretServings?
    
    public init(food_id: String, food_name: String, food_type: String?, food_url: String?, brand_name: String?, servings: FatSecretServings?) {
        self.food_id = food_id
        self.food_name = food_name
        self.food_type = food_type
        self.food_url = food_url
        self.brand_name = brand_name
        self.servings = servings
    }
}

// MARK: - Serving Sizes Container

public struct FatSecretServings: Codable, Hashable {
    public let serving: [FatSecretServing]
    
    public init(serving: [FatSecretServing]) {
        self.serving = serving
    }
}

// MARK: - Nutritional Data

public struct FatSecretServing: Codable, Hashable {
    public let serving_id: String?
    public let serving_description: String?
    public let metric_serving_amount: String?
    public let metric_serving_unit: String?
    public let calories: String?
    public let protein: String?
    public let fat: String?
    public let carbohydrate: String?
    public let fiber: String?
    public let sugar: String?
    public let sodium: String?
    
    public init(serving_id: String?, serving_description: String?, metric_serving_amount: String?, metric_serving_unit: String?, calories: String?, protein: String?, fat: String?, carbohydrate: String?, fiber: String?, sugar: String?, sodium: String?) {
        self.serving_id = serving_id
        self.serving_description = serving_description
        self.metric_serving_amount = metric_serving_amount
        self.metric_serving_unit = metric_serving_unit
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbohydrate = carbohydrate
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
    }
}

// MARK: - Debug Helper

class FatSecretParser {
    static func debugPrintJSON(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            if let jsonString = String(data: prettyData, encoding: .utf8) {
                print("📦 FatSecret API Response:\n\(jsonString)")
            }
        } catch {
            print("❌ Failed to parse JSON for debugging: \(error)")
        }
    }
}
