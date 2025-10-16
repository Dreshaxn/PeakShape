//
//  HomeView.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct HomeView: View {
    @State private var authResult = ""
    @State private var foodResult = ""
    @State private var isLoading = false
    @State private var isSearchingFood = false
    @EnvironmentObject var authViewModel: AuthViewModel

    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("PeakShape")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Welcome to your fitness journey!")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(spacing: 15) {
                    NavigationLink(destination: ProgressView()) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("View Progress")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button("Test FatSecret Auth") {
                        testFatSecretAuth()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading)
                    
                    Button("Test Food Search") {
                        testFoodSearch()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isSearchingFood)
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("Testing Auth...")
                        }
                    }
                    
                    if isSearchingFood {
                        HStack {
                            ProgressView()
                            Text("Searching Foods...")
                        }
                    }
                    
                    if !authResult.isEmpty {
                        Text(authResult)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                    }
                    
                    if !foodResult.isEmpty {
                        Text(foodResult)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Sign Out") {
                        // TODO: Implement sign out
                        authViewModel.signOut() 
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    func testFatSecretAuth() {
        isLoading = true
        authResult = ""
        
        let authService = FatSecretAuthService()
        authService.fetchAccessToken { token in
            DispatchQueue.main.async {
                isLoading = false
                if let token = token {
                    // Show first 20 characters of token for security
                    let tokenPreview = String(token.prefix(20)) + "..."
                    authResult = "✅ Success! Access Token: \(tokenPreview)"
                } else {
                    authResult = "❌ Failed to get access token. Check console for details."
                }
            }
        }
    }
    
    func testFoodSearch() {
        isSearchingFood = true
        foodResult = ""
        
        let foodService = FoodService()
        foodService.searchFoods(query: "apple") { foods, error in
            DispatchQueue.main.async {
                isSearchingFood = false
                if let foods = foods {
                    foodResult = "✅ Found \(foods.count) foods! First: \(foods.first?.name ?? "Unknown")"
                } else if let error = error {
                    foodResult = "❌ Error: \(error.localizedDescription)"
                } else {
                    foodResult = "❌ No foods found"
                }
            }
        }
    }
}

#Preview {
    HomeView()
} 
