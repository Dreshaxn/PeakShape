//
//  FatSecretResponse.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import Foundation

// MARK: - FatSecret Barcode API Response

/**
 Root-level response wrapper from FatSecret API barcode search endpoint.
 
 This struct represents the top-level JSON response structure returned by the FatSecret API
 when performing barcode searches. The barcode API returns a direct food object, not the
 foods_search structure used by the regular search API.
 
 - Note: The API returns all numeric values as strings, not numbers
 - SeeAlso: `FatSecretAPIBarcodeService.scanBarcode(_:completion:)`
 */
public struct FatSecretBarcodeResponse: Codable, Hashable {
    /// The food item found for the barcode
    public let food: FatSecretFood?
    
    /// Initializes a new barcode response
    /// - Parameter food: The food item found for the barcode
    public init(food: FatSecretFood?) {
        self.food = food
    }
}

// MARK: - FatSecret API Response (v4)


/**
 Root-level response wrapper from FatSecret API v4 food search endpoint.
 
 This struct represents the top-level JSON response structure returned by the FatSecret API
 when performing food searches. It contains the search results and metadata.
 
 - Note: The API returns all numeric values as strings, not numbers
 - SeeAlso: `FatSecretAPI.searchFood(_:page:maxResults:completion:)`
 */
public struct FatSecretSearchResponse: Codable, Hashable {
    /// The search results container containing foods and metadata
    public let foods_search: FatSecretFoodsSearch?
    
    /// Initializes a new search response
    /// - Parameter foods_search: The search results container
    public init(foods_search: FatSecretFoodsSearch?) {
        self.foods_search = foods_search
    }
}

/**
 Search metadata and results container from FatSecret API.
 
 Contains pagination information and the actual food search results.
 All numeric values are returned as strings by the API.
 */
public struct FatSecretFoodsSearch: Codable, Hashable {
    /// Maximum number of results requested
    public let max_results: String?
    /// Total number of results available for the search query
    public let total_results: String?
    /// Current page number (0-based)
    public let page_number: String?
    /// Container holding the actual food results
    public let results: FatSecretResults?
    
    /// Initializes search metadata and results
    /// - Parameters:
    ///   - max_results: Maximum results requested
    ///   - total_results: Total available results
    ///   - page_number: Current page number
    ///   - results: Food results container
    public init(max_results: String?, total_results: String?, page_number: String?, results: FatSecretResults?) {
        self.max_results = max_results
        self.total_results = total_results
        self.page_number = page_number
        self.results = results
    }
}

/**
 Results wrapper containing the array of food items.
 
 This struct wraps the array of food items returned by the FatSecret API.
 The API returns food items in a "results" object with a "food" array.
 */
public struct FatSecretResults: Codable, Hashable {
    /// Array of food items returned by the search
    public let food: [FatSecretFood]
    
    /// Initializes results container
    /// - Parameter food: Array of food items
    public init(food: [FatSecretFood]) {
        self.food = food
    }
}

/**
 Represents an individual food item from FatSecret API.
 
 This struct contains all the information about a specific food item including
 its nutritional data, serving sizes, and metadata. Conforms to Identifiable
 for use in SwiftUI Lists.
 
 - Note: All nutritional values are stored as strings as returned by the API
 - SeeAlso: `FatSecretServing` for nutritional information
 */
public struct FatSecretFood: Codable, Identifiable, Hashable {
    /// Unique identifier for SwiftUI List compatibility
    public var id: String { food_id }

    /// Unique identifier for the food item
    public let food_id: String
    /// Human-readable name of the food item
    public let food_name: String
    /// Type of food (e.g., "Generic", "Branded")
    public let food_type: String?
    /// URL to the food's detailed page on FatSecret
    public let food_url: String?
    /// Brand name if this is a branded food item
    public let brand_name: String?
    /// Container holding serving size and nutritional information
    public let servings: FatSecretServings?
    
    /// Initializes a food item
    /// - Parameters:
    ///   - food_id: Unique identifier
    ///   - food_name: Display name
    ///   - food_type: Type classification
    ///   - food_url: Detail page URL
    ///   - brand_name: Brand name if applicable
    ///   - servings: Nutritional data container
    public init(food_id: String, food_name: String, food_type: String?, food_url: String?, brand_name: String?, servings: FatSecretServings?) {
        self.food_id = food_id
        self.food_name = food_name
        self.food_type = food_type
        self.food_url = food_url
        self.brand_name = brand_name
        self.servings = servings
    }
}

/**
 Container for serving size information and nutritional data.
 
 This struct wraps the array of serving sizes available for a food item.
 Each food can have multiple serving sizes (e.g., "1 slice", "100g", "1 cup").
 */
public struct FatSecretServings: Codable, Hashable {
    /// Array of serving size options with nutritional data
    public let serving: [FatSecretServing]
    
    /// Initializes servings container
    /// - Parameter serving: Array of serving size options
    public init(serving: [FatSecretServing]) {
        self.serving = serving
    }
}

/**
 Represents a single serving size with complete nutritional information.
 
 This struct contains all nutritional data for a specific serving size of a food item.
 All values are stored as strings as returned by the FatSecret API, which allows
 for precise decimal values and handles missing data gracefully.
 
 - Note: All nutritional values are strings, not numbers
 - Important: Use `Double(stringValue)` to convert to numeric values for calculations
 */
public struct FatSecretServing: Codable, Hashable {
    /// Unique identifier for this serving size
    public let serving_id: String?
    /// Human-readable description (e.g., "1 thin slice", "100g")
    public let serving_description: String?
    /// Metric amount for this serving
    public let metric_serving_amount: String?
    /// Metric unit (e.g., "g", "ml", "cup")
    public let metric_serving_unit: String?
    /// Calories per serving
    public let calories: String?
    /// Protein content in grams
    public let protein: String?
    /// Fat content in grams
    public let fat: String?
    /// Carbohydrate content in grams
    public let carbohydrate: String?
    /// Fiber content in grams
    public let fiber: String?
    /// Sugar content in grams
    public let sugar: String?
    /// Sodium content in milligrams
    public let sodium: String?
    
    /// Initializes a serving with nutritional data
    /// - Parameters:
    ///   - serving_id: Unique identifier
    ///   - serving_description: Human-readable description
    ///   - metric_serving_amount: Metric amount
    ///   - metric_serving_unit: Metric unit
    ///   - calories: Calories per serving
    ///   - protein: Protein in grams
    ///   - fat: Fat in grams
    ///   - carbohydrate: Carbs in grams
    ///   - fiber: Fiber in grams
    ///   - sugar: Sugar in grams
    ///   - sodium: Sodium in mg
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
