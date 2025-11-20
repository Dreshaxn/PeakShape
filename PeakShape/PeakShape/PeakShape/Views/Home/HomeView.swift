//
//  HomeView.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("PeakShape")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let profile = firestoreViewModel.userProfile {
                    Text("Welcome back, \(profile.name)!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    // Display calorie information using CalorieCalculatorService
                    let calorieResult = profile.calculateCalorieGoal()
                    
                    VStack(spacing: 12) {
                        Text("Your Daily Calorie Goal")
                            .font(.headline)
                        
                        Text("\(Int(calorieResult.targetCalories)) calories")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Based on your \(profile.weightGoal.title.lowercased()) goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !calorieResult.notes.isEmpty {
                            Text(calorieResult.notes)
                                .font(.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    Text("Welcome to your fitness journey!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                NavigationLink(destination: SearchFoodView()) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search for Food")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                NavigationLink(destination: ScanFoodView()) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scan Barcode")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button("signOut") {
                    authViewModel.signOut()               }
                    
                }
                Spacer()
            }
            .padding()
        }
    }

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(FirestoreViewModel())
}
