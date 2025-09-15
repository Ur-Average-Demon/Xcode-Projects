//
//  ContentView.swift
//  Tic Tac Toe
//
//  Created by Justin Gangaram on 8/8/25.
//

import SwiftUI

struct ContentView: View {
    enum Player {
        case x, o
        var symbol: String {
            switch self {
            case .x: return "X"
            case .o: return "O"
            }
        }
        var opposite: Player {
            self == .x ? .o : .x
        }
    }

    @State private var board = Array(repeating: "", count: 9)
    @State private var currentPlayer: Player = .x
    @State private var gameOver = false
    @State private var message = ""
    @State private var xScore = 0
    @State private var oScore = 0
    @State private var drawCount = 0
    @State private var isVsAI = false

    let winningIndices = [
        [0,1,2],[3,4,5],[6,7,8], // rows
        [0,3,6],[1,4,7],[2,5,8], // columns
        [0,4,8],[2,4,6]          // diagonals
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Tic Tac Toe")
                .font(.largeTitle)
                .bold()
                .padding()

            // Mode toggle
            HStack {
                Text("Mode:")
                Spacer()
                Button(action: {
                    resetBoard()
                    isVsAI.toggle()
                }) {
                    Text(isVsAI ? "VS AI" : "2 Players")
                        .bold()
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            Text("Current Player: \(currentPlayer.symbol)")
                .font(.title2)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(0..<9) { i in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.blue.opacity(0.7))
                            .cornerRadius(10)
                            .frame(height: 100)
                        Text(board[i])
                            .font(.system(size: 64))
                            .bold()
                            .foregroundColor(.white)
                    }
                    .onTapGesture {
                        playerMove(at: i)
                    }
                    .disabled(board[i] != "" || gameOver || (isVsAI && currentPlayer == .o))
                }
            }
            .padding()

            Text(message)
                .font(.title2)
                .foregroundColor(.red)

            HStack(spacing: 40) {
                VStack {
                    Text("X Wins")
                    Text("\(xScore)")
                        .font(.title)
                }
                VStack {
                    Text("Draws")
                    Text("\(drawCount)")
                        .font(.title)
                }
                VStack {
                    Text("O Wins")
                    Text("\(oScore)")
                        .font(.title)
                }
            }
            .padding()

            Button("Reset Game") {
                resetBoard()
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onChange(of: currentPlayer) { _ in
            if isVsAI && currentPlayer == .o && !gameOver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    aiMove()
                }
            }
        }
    }

    func playerMove(at index: Int) {
        guard board[index] == "" && !gameOver else { return }
        board[index] = currentPlayer.symbol
        if checkWin(for: currentPlayer.symbol) {
            message = "\(currentPlayer.symbol) Wins!"
            gameOver = true
            updateScore(winner: currentPlayer)
        } else if !board.contains("") {
            message = "It's a Draw!"
            gameOver = true
            drawCount += 1
        } else {
            togglePlayer()
        }
    }

    func checkWin(for symbol: String) -> Bool {
        for combo in winningIndices {
            if combo.allSatisfy({ board[$0] == symbol }) {
                return true
            }
        }
        return false
    }

    func togglePlayer() {
        currentPlayer = currentPlayer.opposite
    }

    func updateScore(winner: Player) {
        if winner == .x {
            xScore += 1
        } else {
            oScore += 1
        }
    }

    func resetBoard() {
        board = Array(repeating: "", count: 9)
        currentPlayer = .x
        message = ""
        gameOver = false
    }

    // MARK: - Simple AI logic: Win, block, or random move
    func aiMove() {
        // 1. Win if possible
        if let winIndex = findBestMove(for: currentPlayer.symbol) {
            board[winIndex] = currentPlayer.symbol
            checkAfterAIMove()
            return
        }

        // 2. Block player win
        let opponentSymbol = currentPlayer.opposite.symbol
        if let blockIndex = findBestMove(for: opponentSymbol) {
            board[blockIndex] = currentPlayer.symbol
            checkAfterAIMove()
            return
        }

        // 3. Otherwise pick random empty cell
        let emptyIndices = board.indices.filter { board[$0] == "" }
        if let randomIndex = emptyIndices.randomElement() {
            board[randomIndex] = currentPlayer.symbol
            checkAfterAIMove()
        }
    }

    func findBestMove(for symbol: String) -> Int? {
        for combo in winningIndices {
            let marks = combo.map { board[$0] }
            let countSymbol = marks.filter { $0 == symbol }.count
            let countEmpty = marks.filter { $0 == "" }.count
            if countSymbol == 2 && countEmpty == 1 {
                if let emptyIndexInCombo = combo.first(where: { board[$0] == "" }) {
                    return emptyIndexInCombo
                }
            }
        }
        return nil
    }

    func checkAfterAIMove() {
        if checkWin(for: currentPlayer.symbol) {
            message = "\(currentPlayer.symbol) Wins!"
            gameOver = true
            updateScore(winner: currentPlayer)
        } else if !board.contains("") {
            message = "It's a Draw!"
            gameOver = true
            drawCount += 1
        } else {
            togglePlayer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

