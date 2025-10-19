//
//  ScanFood.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

/**
 Barcode scanning interface using FatSecret API integration.
 
 This view provides a complete barcode scanning experience with real-time results
 from the FatSecret database. Users can enter barcode numbers manually or scan
 them using the device camera to get detailed nutritional information.
 
 Features:
 - Manual barcode number entry
 - Real-time barcode lookup using FatSecret API
 - Nutritional information display
 - Loading states and error handling
 - Responsive UI with barcode results
 
 - Note: Requires valid FatSecret API credentials with premier scope
 - SeeAlso: `FatSecretAPIBarcodeService` for API integration
 */
struct ScanFoodView: View {
    /// Current barcode number entered by user
    @State private var barcodeNumber = ""
    /// Barcode search result from API
    @State private var barcodeResult: FatSecretBarcodeResponse?
    /// Loading state indicator
    @State private var isLoading = false
    /// Error message to display to user
    @State private var errorMessage: String?
    /// Success message to display
    @State private var successMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Section
                VStack(spacing: 12) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Scan Barcode")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Enter a barcode number to find nutritional information")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                //Barcode Input Section
                VStack(spacing: 16) {
                    HStack {
                        TextField("Enter barcode number...", text: $barcodeNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .disableAutocorrection(true)
                            .onChange(of: barcodeNumber) { _ in
                                // Clear previous results when barcode changes
                                barcodeResult = nil
                                errorMessage = nil
                                successMessage = nil
                            }
                        
                        Button {
                            scanBarcode()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(barcodeNumber.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                                )
                        }
                        .disabled(barcodeNumber.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                    }
                    .padding(.horizontal)
                    
                    // 🌀 Loading state
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching barcode...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                
                // 📋 Results Section
                if let result = barcodeResult, let food = result.food {
                    VStack(alignment: .leading, spacing: 16) {
                        // Success message
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Barcode found!")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        
                        // Food information
                        VStack(alignment: .leading, spacing: 12) {
                            // Food name and brand
                            VStack(alignment: .leading, spacing: 4) {
                                Text(food.food_name)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                if let brand = food.brand_name {
                                    Text(brand)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Nutritional information
                            if let servings = food.servings?.serving.first {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nutritional Information")
                                        .font(.headline)
                                        .padding(.top, 8)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 8) {
                                        if let calories = servings.calories, let cal = Double(calories) {
                                            NutritionCard(title: "Calories", value: "\(Int(cal)) kcal", color: .orange)
                                        }
                                        if let protein = servings.protein, let prot = Double(protein) {
                                            NutritionCard(title: "Protein", value: "\(String(format: "%.1f", prot))g", color: .red)
                                        }
                                        if let carbs = servings.carbohydrate, let carb = Double(carbs) {
                                            NutritionCard(title: "Carbs", value: "\(String(format: "%.1f", carb))g", color: .blue)
                                        }
                                        if let fat = servings.fat, let fatVal = Double(fat) {
                                            NutritionCard(title: "Fat", value: "\(String(format: "%.1f", fatVal))g", color: .purple)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal)
                } else if !isLoading && !barcodeNumber.isEmpty {
                    Text("No food found for this barcode number.")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                // ❌ Error message
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Barcode Scanner")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Barcode Scanning Function
    
    /**
     Performs barcode search using FatSecret API.
     
     This method handles the complete barcode search workflow:
     1. Validates barcode number is not empty
     2. Sets loading state and clears previous results
     3. Calls FatSecret API with barcode number
     4. Updates UI with results or error message
     
     - Note: Barcode number is trimmed of whitespace before API call
     - Important: Results are updated on main thread for UI safety
     */
    func scanBarcode() {
        let trimmedBarcode = barcodeNumber.trimmingCharacters(in: .whitespaces)
        guard !trimmedBarcode.isEmpty else { return }
        
        isLoading = true
        barcodeResult = nil
        errorMessage = nil
        successMessage = nil
        
        FatSecretAPIBarcodeService.scanBarcode(trimmedBarcode) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    print("Barcode: \(trimmedBarcode)")
                    print("Full Response: \(response)")
                    print("Food: \(response.food)")
                    
                    barcodeResult = response
                    
                    if response.food != nil {
                        successMessage = "Barcode found successfully!"
                        print("Found barcode result: \(response.food?.food_name ?? "Unknown")")
                    } else {
                        errorMessage = "No food found for this barcode number."
                        print("No food found in response")
                    }
                case .failure(let error):
                    errorMessage = "Error searching barcode: \(error.localizedDescription)"
                    print("Barcode API Error:", error)
                }
            }
        }
    }
}

/**
 Custom nutrition card component for displaying nutritional information.
 
 This view creates a styled card showing nutritional data with color coding
 for different types of nutrients.
 */
struct NutritionCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    ScanFoodView()
}
