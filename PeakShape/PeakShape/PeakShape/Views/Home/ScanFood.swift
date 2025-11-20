//
//  ScanFood.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct ScanFoodView: View {
    @State private var barcodeNumber = ""
    @State private var barcodeResult: FatSecretBarcodeResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var selectedServingIndex = 0

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
                    
                    // Loading state
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
                
                // Results Section
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
                                
                                // Nutritional Information
                                if selectedServingIndex < servings.count {
                                    let selectedServing = servings[selectedServingIndex]
                                    NutritionDetailCard(serving: selectedServing)
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
                
                // Error message
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
    
    func scanBarcode() {
        let trimmedBarcode = barcodeNumber.trimmingCharacters(in: .whitespaces)
        guard !trimmedBarcode.isEmpty else { return }
        
        // Convert barcode to GTIN-13 format
        guard let gtin13Barcode = BarcodeConverter.convertToGTIN13(trimmedBarcode) else {
            errorMessage = "Invalid barcode format. Please enter a valid EAN-8, EAN-13, UPC-A, or UPC-E barcode."
            return
        }
        
        // Show barcode type detection
        if let barcodeType = BarcodeConverter.detectBarcodeType(trimmedBarcode) {
            print("Detected barcode type: \(barcodeType.rawValue)")
        }
        
        isLoading = true
        barcodeResult = nil
        errorMessage = nil
        successMessage = nil
        selectedServingIndex = 0
        
        print("Original barcode: \(trimmedBarcode)")
        print("Converted to GTIN-13: \(gtin13Barcode)")
        
        FatSecretAPIBarcodeService.scanBarcode(gtin13Barcode) { result in
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


#Preview {
    ScanFoodView()
}
