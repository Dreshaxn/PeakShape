import Foundation

/// Represents a food item with nutritional information from the FatSecret API
public struct Food: Codable {
    // MARK: - Properties
    
    /// Unique identifier for the food item
    public let id: String
    /// Human-readable name of the food item
    public let name: String
    /// Category or classification of the food (e.g., "Generic", "Branded")
    public let type: String
    /// URL to the food item's detailed information page
    public let url: String
    /// Array of serving sizes with nutritional information
    public let servings: [Serving]?
}

/// Represents a serving size with nutritional information
public struct Serving: Codable {
    /// Unique identifier for the serving
    public let serving_id: String?
    /// Description of the serving (e.g., "1 medium apple", "100g")
    public let serving_description: String?
    /// Metric serving amount
    public let metric_serving_amount: String?
    /// Metric serving unit
    public let metric_serving_unit: String?
    /// Number of calories
    public let calories: String?
    /// Carbohydrate content
    public let carbohydrate: String?
    /// Protein content
    public let protein: String?
    /// Fat content
    public let fat: String?
    /// Sugar content
    public let sugar: String?
    /// Sodium content
    public let sodium: String?
    /// Fiber content
    public let fiber: String?
}

// MARK: - Food Service

/// Service class for making API calls to your local FatSecret proxy server
public class FoodService {
    private let baseURL = "http://localhost:3000"
    
    public init() {}
    
    /// Search for foods using your local proxy server
    /// - Parameters:
    ///   - query: The search term (e.g., "apple", "chicken breast")
    ///   - completion: Callback with array of Food items or error
    public func searchFoods(query: String, completion: @escaping ([Food]?, Error?) -> Void) {
        // Create the search URL with query parameters
        var components = URLComponents(string: "\(baseURL)/searchFood")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = components.url else {
            completion(nil, NSError(domain: "FoodService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Create the request - no authorization needed!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Make the API call to your local server
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "FoodService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Parse the response from your proxy server
            do {
                let decoder = JSONDecoder()
                // The proxy server returns the same structure as FatSecret
                let searchResponse = try decoder.decode(FoodSearchResponse.self, from: data)
                completion(searchResponse.foods?.food, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    /// Get detailed information about a specific food by ID
    /// - Parameters:
    ///   - foodId: The unique identifier for the food
    ///   - completion: Callback with Food item or error
    public func getFoodDetails(foodId: String, completion: @escaping (Food?, Error?) -> Void) {
        // Create the URL for getting food details
        var components = URLComponents(string: "\(baseURL)/getFood")!
        components.queryItems = [
            URLQueryItem(name: "id", value: foodId)
        ]
        
        guard let url = components.url else {
            completion(nil, NSError(domain: "FoodService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "FoodService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let foodResponse = try decoder.decode(FoodDetailResponse.self, from: data)
                completion(foodResponse.food, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

// MARK: - Response Models

/// Response wrapper for food search results
public struct FoodSearchResponse: Codable {
    let foods: FoodSearchWrapper?
}

public struct FoodSearchWrapper: Codable {
    let food: [Food]
}

/// Response wrapper for individual food details
public struct FoodDetailResponse: Codable {
    let food: Food
}