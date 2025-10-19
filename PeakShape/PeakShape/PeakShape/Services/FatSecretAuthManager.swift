//
//  FatSecretAuthManager.swift
//  PeakShape
//
//  Created by Dreshawn Young on 10/16/25.
//
import Foundation

/**
 Manages FatSecret API authentication tokens with caching and automatic renewal.
 
 This singleton class handles OAuth 2.0 client credentials flow for FatSecret API,
 providing token caching, expiration management, and automatic token refresh.
 
 Features:
 - Token caching to avoid unnecessary API calls
 - Automatic token renewal when expired
 - 24-hour token expiration handling
 
 - Note: Tokens are cached for 24 hours (86400 seconds)
 - SeeAlso: `FatSecretAuthService` for OAuth implementation
 */
public class FatSecretAuthManager {
    /// Shared singleton instance
    static let ourOneAuthManager = FatSecretAuthManager()

    /// Cached access token
    private var accessToken: String?
    /// Token expiration date
    private var expirationDate: Date?
    /// Authentication service for token requests
    private let service = FatSecretAuthService()

    private init() {}

    /**
     Gets a valid authentication token, using cache if available.
     
     This method checks if a valid token is already cached and not expired.
     If no valid token exists, it requests a new one from the authentication service.
     
     - Parameter completion: Callback with valid token or nil if authentication failed
     - Note: Tokens are automatically cached for 24 hours
     - Important: Always call this method before making API requests
     */
    public func getValidToken(completion: @escaping (String?) -> Void) {
        // If we already have a token and it's not expired, reuse it
        if let token = accessToken, let expires = expirationDate, Date() < expires {
            completion(token)
            return
        }

        // Otherwise, fetch a new one
        service.fetchAccessToken { token in
            guard let token = token else {
                completion(nil)
                return
            }
            // FatSecret tokens last 24h (86400s)
            self.accessToken = token
            self.expirationDate = Date().addingTimeInterval(86400)
            completion(token)
        }
    }
}
