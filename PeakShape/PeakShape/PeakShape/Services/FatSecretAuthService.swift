import Foundation

public struct FatSecretAuthResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

public class FatSecretAuthService {
    private let clientId = "f3e512c85237472caca3c030ac0b7397"
    private let clientSecret = "57c81fa4d83b43bfac574c469c4807c2"
    private let tokenURL = URL(string: "https://oauth.fatsecret.com/connect/token")!
    
    public init() {}
    
    public func fetchAccessToken(completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        // Encode ClientID:ClientSecret in Base64
        let credentials = "\(clientId):\(clientSecret)"
        let encoded = Data(credentials.utf8).base64EncodedString()
        request.addValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // grant_type=client_credentials&scope=basic
        let body = "grant_type=client_credentials&scope=basic"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            if let response = try? decoder.decode(FatSecretAuthResponse.self, from: data) {
                completion(response.access_token)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
