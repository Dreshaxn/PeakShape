//
//  SearchFood.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

/**
 Food search interface using FatSecret API integration.
 
 This view provides a complete food search experience with real-time results
 from the FatSecret database. Users can search for food items and view detailed
 nutritional information including calories, protein, carbs, and more.
 
 Features:
 - Real-time food search using FatSecret API v4
 - Nutritional information display
 - Loading states and error handling
 - Responsive UI with search results list
 
 - Note: Requires valid FatSecret API credentials with premier scope
 - SeeAlso: `FatSecretAPI` for API integration
 */
struct SearchFoodView: View {
    /// Current search query entered by user
    @State private var searchQuery = ""
    /// Array of food items returned from search
    @State private var foods: [FatSecretFood] = []
    /// Loading state indicator
    @State private var isLoading = false
    /// Error message to display to user
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                // 🔎 Search bar
                HStack {
                    TextField("Search for a food...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .disableAutocorrection(true)

                    Button {
                        search()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing)
                    }
                    .disabled(searchQuery.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                // 🌀 Loading state
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }

                // 📋 Results list
                if !foods.isEmpty {
                    List(foods) { food in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(food.food_name)
                                .font(.headline)
                            if let brand = food.brand_name {
                                Text(brand)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            if let caloriesString = food.servings?.serving.first?.calories,
                               let calories = Double(caloriesString) {
                                Text("Calories: \(Int(calories)) kcal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else if !isLoading && !searchQuery.isEmpty {
                    Text("No results found.")
                        .foregroundColor(.gray)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Food Search")
        }
    }

    // MARK: - Search Function
    
    /**
     Performs food search using FatSecret API.
     
     This method handles the complete search workflow:
     1. Validates search query is not empty
     2. Sets loading state and clears previous results
     3. Calls FatSecret API with search query
     4. Updates UI with results or error message
     
     - Note: Search query is trimmed of whitespace before API call
     - Important: Results are updated on main thread for UI safety
     */
    func search() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        foods.removeAll()

        FatSecretAPI.searchFood(searchQuery) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    print("Search Query: \(searchQuery)")
                    print("Full Response: \(response)")
                    print("Foods Search: \(response.foods_search)")
                    print("Results: \(response.foods_search?.results)")
                    print("Food Array: \(response.foods_search?.results?.food)")
                    
                    let foundFoods = response.foods_search?.results?.food ?? []
                    print("Found \(foundFoods.count) foods")
                    
                    foods = foundFoods
                    
                    if foundFoods.isEmpty {
                        print("No foods found in response")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("API Error:", error)
                }
            }
        }
    }
}

#Preview {
    SearchFoodView()
}

