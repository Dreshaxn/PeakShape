//
//  NutritionComponents.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct NutritionDetailCard: View {
    let serving: FatSecretServing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutritional Information")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NutritionItem(
                    title: "Calories",
                    value: serving.calories,
                    unit: "kcal",
                    color: .orange
                )
                
                NutritionItem(
                    title: "Protein",
                    value: serving.protein,
                    unit: "g",
                    color: .red
                )
                
                NutritionItem(
                    title: "Fat",
                    value: serving.fat,
                    unit: "g",
                    color: .yellow
                )
                
                NutritionItem(
                    title: "Carbs",
                    value: serving.carbohydrate,
                    unit: "g",
                    color: .green
                )
                
                NutritionItem(
                    title: "Fiber",
                    value: serving.fiber,
                    unit: "g",
                    color: .brown
                )
                
                NutritionItem(
                    title: "Sugar",
                    value: serving.sugar,
                    unit: "g",
                    color: .pink
                )
                
                NutritionItem(
                    title: "Sodium",
                    value: serving.sodium,
                    unit: "mg",
                    color: .blue
                )
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}

struct NutritionItem: View {
    let title: String
    let value: String?
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatValue(value) ?? "0")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
    
    private func formatValue(_ value: String?) -> String? {
        guard let value = value, let doubleValue = Double(value) else { return nil }
        return String(format: "%.1f", doubleValue)
    }
}
