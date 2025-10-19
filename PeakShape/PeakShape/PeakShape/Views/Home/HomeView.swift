//
//  HomeView.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI

struct HomeView: View {
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
}
