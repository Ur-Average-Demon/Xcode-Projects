//
//  EndSheetView.swift
//  Math Minute
//
//  Created by Justin Gangaram on 8/8/25.
//

import SwiftUI

struct EndSheetView: View {
    let score: Int
    @Binding var bestScore: Int
    var restartAction: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Time's Up!")
                    .font(.largeTitle)
                    .bold()
                Text("Score: \(score)")
                    .font(.title)
                Text("Best: \(bestScore)")
                    .font(.title2)
                Button(action: restartAction) {
                    Text("Play Again")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.padding()

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
