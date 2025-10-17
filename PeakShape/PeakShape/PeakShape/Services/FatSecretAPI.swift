import Foundation

/**
 FatSecret API service for searching food items with nutritional information.
 
 This service provides access to the FatSecret API v4 food search endpoint,
 which requires premier scope access. It handles authentication, request building,
 and response parsing for food search functionality.
 
 - Note: Requires valid FatSecret API credentials with premier scope
 - SeeAlso: `FatSecretAuthManager` for authentication handling
 */
public class FatSecretAPI {
    
    /**
     Searches for food items using the FatSecret API v4 endpoint.
     
     This method performs a food search query against the FatSecret database,
     returning detailed nutritional information for each food item found.
     
     - Parameters:
       - query: The search term (e.g., "apple", "chicken breast")
       - page: Page number for pagination (default: 0)
       - maxResults: Maximum number of results to return (default: 10)
       - completoin: Callback with search results or error
     
     - Returns: `Result<FatSecretSearchResponse, Error>`
       - Success: Contains array of food items with nutritional data
       - Failure: Network error, authentication error, or parsing error
     
     - Note: All nutritional values are returned as strings from the API
     - Important: Requires valid authentication token with premier scope
     
     */
    public static func searchFood(
        _ query: String, // The search term (e.g., "apple", "chicken breast")
        page: Int = 0, // Page number for pagination (default: 0)
        maxResults: Int = 10, // Maximum number of results to return (default: 10)
        completion: @escaping (Result<FatSecretSearchResponse, Error>) -> Void // Callback with search results or error
    ) {
        FatSecretAuthManager.shared.getValidToken { token in // Get a valid authentication token with premier scope 
            guard let token = token else { // If no token is received, return an authentication error
                print("Authentication failed - no token received")
                completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token"]))) // Return an authentication error
                return
            }
            
            print("🔑 Using token: \(String(token.prefix(20)))...") // Print the first 20 characters of the token for debugging purposes

            var components = URLComponents(string: "https://platform.fatsecret.com/rest/foods/search/v4")! // Create a URLComponents object with the FatSecret API endpoint
            components.queryItems = [
                URLQueryItem(name: "search_expression", value: query), // Add the search term to the query
                URLQueryItem(name: "page_number", value: "\(page)"), // Add the page number to the query
                URLQueryItem(name: "max_results", value: "\(maxResults)"), // Add the maximum number of results to the query
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "flag_default_serving", value: "true"), // Add the flag for default serving to the query
                URLQueryItem(name: "region", value: "US") // Add the region to the query
            ]

            var request = URLRequest(url: components.url!) // Create a URLRequest object with the URLComponents object
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Add the token to the request header

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error { // If an error is received, return a network error
                    print("Network error:", error)
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse { // If an HTTP response is received, print the status code
                    print("HTTP Status: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 { // If the status code is not 200, print a warning 
                        print("⚠️ Non-200 status code: \(httpResponse.statusCode)")
                    }
                }
                
                guard let data = data else { // If no data is received, return a data error
                    print("No data returned from API")
                    completion(.failure(NSError(domain: "Data", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
                    return
                }

                do { // Try to decode the data into a FatSecretSearchResponse object
                    // Debug: Print raw JSON first
                    if let jsonString = String(data: data, encoding: .utf8) { // If the data can be converted to a string, print the string
                        print("Raw API Response:")
                        print(jsonString)
                    }
                    
                    let decoded = try JSONDecoder().decode(FatSecretSearchResponse.self, from: data) // Try to decode the data into a FatSecretSearchResponse object
                    print("Successfully decoded response")
                    completion(.success(decoded))
                } catch {
                    print("Decoding error:", error) // If the data cannot be decoded, print an error
                    print("Raw data:", String(data: data, encoding: .utf8) ?? "Could not convert to string")
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
