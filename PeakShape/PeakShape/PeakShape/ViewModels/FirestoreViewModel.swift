//
//  FirestoreViewModel.swift
//  PeakShape
//
//  Created by Dreshawn Young on 10/27/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class FirestoreViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen for auth state changes
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.loadUserProfile(userId: user.uid)
            } else {
                self?.userProfile = nil
            }
        }
    }
    
    // MARK: - User Profile Management
    
    /// Save user profile to Firestore
    func saveUserProfile(_ profile: UserProfile, userId: String) {
        isLoading = true
        errorMessage = nil
        
        let profileData: [String: Any] = [
            "name": profile.name,
            "sex": profile.sex.rawValue,
            "age": profile.age,
            "height": profile.height,
            "weight": profile.weight,
            "activityLevel": profile.activityLevel.title,
            "goalWeight": profile.goalWeight,
            "weightGoal": profile.weightGoal.title,
            "weeklyWeightChange": profile.weeklyWeightChange as Any,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).setData(profileData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to save profile: \(error.localizedDescription)"
                } else {
                    self?.userProfile = profile
                }
            }
        }
    }
    
    /// Load user profile from Firestore
    private func loadUserProfile(userId: String) {
        isLoading = true
        errorMessage = nil
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data() else {
                    // No profile found - user needs to complete onboarding
                    self?.userProfile = nil
                    return
                }
                
                do {
                    self?.userProfile = try self?.parseUserProfile(from: data)
                } catch {
                    self?.errorMessage = "Failed to parse profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Parse Firestore document data into UserProfile
    private func parseUserProfile(from data: [String: Any]) throws -> UserProfile {
        guard let name = data["name"] as? String,
              let sexString = data["sex"] as? String,
              let sex = Sex(rawValue: sexString),
              let age = data["age"] as? Int,
              let height = data["height"] as? Double,
              let weight = data["weight"] as? Double,
              let activityLevelString = data["activityLevel"] as? String,
              let activityLevel = UserActivityLevel.allCases.first(where: { $0.title == activityLevelString }),
              let goalWeight = data["goalWeight"] as? Double,
              let weightGoalString = data["weightGoal"] as? String,
              let weightGoal = UserWeightGoal.allCases.first(where: { $0.title == weightGoalString }) else {
            throw FirestoreError.invalidData
        }
        
        let weeklyWeightChange = data["weeklyWeightChange"] as? Double
        
        return UserProfile(
            name: name,
            sex: sex,
            age: age,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            goalWeight: goalWeight,
            weightGoal: weightGoal,
            weeklyWeightChange: weeklyWeightChange
        )
    }
    
    /// Update user profile
    func updateUserProfile(_ profile: UserProfile, userId: String) {
        saveUserProfile(profile, userId: userId)
    }
    
    /// Check if user has completed onboarding
    var hasCompletedOnboarding: Bool {
        return userProfile != nil
    }
}

// MARK: - Error Types
enum FirestoreError: Error, LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid profile data"
        }
    }
}