//
//  SearchFood.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct SearchFoodView: View {
    @State private var searchQuery = ""
    @State private var foods: [FatSecretFood] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                // Search bar
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

                // Loading state
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }

                // Results list
                if !foods.isEmpty {
                    List(foods) { food in
                        NavigationLink(destination: FoodDetailView(food: food)) {
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

    func search() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        foods.removeAll()

        FatSecretAPI.searchFood(searchQuery) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    
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

