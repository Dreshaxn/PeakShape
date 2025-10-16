//
//  ProgressView.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct ProgressView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                ProgressCard(title: "Workouts", value: "12", subtitle: "This month")
                ProgressCard(title: "Calories", value: "2,450", subtitle: "Burned today")
                ProgressCard(title: "Steps", value: "8,432", subtitle: "Today's goal")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        ProgressView()
    }
} 