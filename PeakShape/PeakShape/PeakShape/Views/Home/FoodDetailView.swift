//
//  FoodDetailView.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct FoodDetailView: View {
    let food: FatSecretFood
    @State private var selectedServingIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(food.food_name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let brand = food.brand_name {
                        Text(brand)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    if let type = food.food_type {
                        Text(type)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                // Serving Size Picker
                if let servings = food.servings?.serving, !servings.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Serving Size")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("Serving Size", selection: $selectedServingIndex) {
                            ForEach(0..<servings.count, id: \.self) { index in
                                Text(servings[index].serving_description ?? "Unknown")
                                    .tag(index)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 120)
                        .padding(.horizontal)
                    }
                    
                    if selectedServingIndex < servings.count {
                        let selectedServing = servings[selectedServingIndex]
                        NutritionDetailCard(serving: selectedServing)
                    }
                } else {
                    Text("No serving information available")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
