//
//  GettingStarted.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/17/25.
//
import SwiftUI

struct GettingStarted: View {
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
                    
                    Button("Sign Out") {
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
}

#Preview {
    HomeView()
}
