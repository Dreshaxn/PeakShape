import Foundation

public class FatSecretAPIBarcodeService {

    public static func scanBarcode(
        _ barcode: String, 
        completion: @escaping (Result<FatSecretBarcodeResponse, Error>) -> Void
    ) {
        FatSecretAuthManager.shared.getValidToken { token in
            guard let token = token else {
                completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token"])))
                return
            }
            
            print("Using token: \(String(token.prefix(20)))...")
            let url = URL(string: "https://platform.fatsecret.com/rest/food/barcode/find-by-id/v2?barcode=\(barcode)&format=json")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error:", error)
                    completion(.failure(error))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        print("Non-200 status code: \(httpResponse.statusCode)")
                    }
                }
                guard let data = data else {
                    print("No data returned from API")
                    completion(.failure(NSError(domain: "Data", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
                    return
                }
                
                // Print the full raw response before decoding
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("🔍 Full Barcode API Response:")
                    print(String(repeating: "=", count: 50))
                    print(rawResponse)
                    print(String(repeating: "=", count: 50))
                }
                
                do {
                    let decoded = try JSONDecoder().decode(FatSecretBarcodeResponse.self, from: data)
                    print("Successfully decoded response")
                    completion(.success(decoded))
                } catch {
                    print("Decoding error:", error)
                    print("Raw data:", String(data: data, encoding: .utf8) ?? "Could not convert to string")
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
