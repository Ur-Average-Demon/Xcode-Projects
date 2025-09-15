//
//  ContentView.swift
//  Math Minute
//
//  Created by Justin Gangaram on 8/8/25.
//

import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case light, dark, neon
    var id: String { rawValue }
    var background: LinearGradient {
        switch self {
        case .light:
            return LinearGradient(colors: [Color(.systemTeal).opacity(0.2), Color(.systemBlue).opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dark:
            return LinearGradient(colors: [Color.black, Color(.systemIndigo)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .neon:
            return LinearGradient(colors: [Color.purple, Color.pink, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    var foregroundColor: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        case .neon: return .white
        }
    }
}

struct ContentView: View {
    // Game state
    @State private var currentProblem = ""
    @State private var answer = ""
    @State private var score = 0
    @AppStorage("bestScore") private var bestScore = 0
    @State private var timeRemaining = 60
    @State private var gameActive = false
    @State private var correctAnswer = 0
    @State private var timer: Timer? = nil
    @State private var difficulty = "Easy"
    let difficulties = ["Easy", "Medium", "Hard"]

    // UI
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = Theme.light.rawValue
    private var theme: Theme { Theme(rawValue: selectedThemeRaw) ?? .light }
    @State private var showSettings = false
    @State private var showEndSheet = false
    @State private var circleProgress: Double = 1.0

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(spacing: 18) {
                HStack {
                    Text("Math Minute")
                        .font(.largeTitle).bold()
                        .foregroundColor(theme.foregroundColor)
                    Spacer()
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(theme.foregroundColor)
                    }
                }.padding(.horizontal)

                HStack {
                    Text("Time")
                        .foregroundColor(theme.foregroundColor.opacity(0.8))
                    Spacer()
                    Text("\(timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(.red)
                }.padding(.horizontal)

                // Animated circular countdown + score
                ZStack {
                    Circle()
                        .stroke(lineWidth: 14)
                        .opacity(0.15)
                        .foregroundColor(theme.foregroundColor)
                        .frame(width: 180, height: 180)

                    Circle()
                        .trim(from: 0, to: CGFloat(circleProgress))
                        .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.2), value: circleProgress)
                        .frame(width: 180, height: 180)

                    VStack {
                        Text("\(score)")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(theme.foregroundColor)
                        Text("Score")
                            .foregroundColor(theme.foregroundColor.opacity(0.8))
                    }
                }
                .padding()

                Text(currentProblem)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(theme.foregroundColor)
                    .padding(.top, 6)

                HStack {
                    TextField("Answer", text: $answer, onCommit: checkAnswer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 140)
                    Button(action: checkAnswer) {
                        Text("Submit")
                            .bold()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor))
                            .foregroundColor(.white)
                    }
                }

                if !gameActive {
                    VStack(spacing: 12) {
                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(difficulties, id: \.self) { d in Text(d) }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)

                        Text("Best Score: \(bestScore)")
                            .foregroundColor(theme.foregroundColor)

                        Button(action: startGame) {
                            Text("Start Game")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue))
                                .foregroundColor(.white)
                        }.padding(.horizontal)
                    }
                } else {
                    Button(action: endGame) {
                        Text("End Game")
                            .bold()
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.red))
                            .foregroundColor(.white)
                    }.padding(.top, 8)
                }

                Spacer()
            }
            .padding(.top, 30)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                // load initial problem for visual polish
                if !gameActive { prepareNextProblem() }
            }
            .sheet(isPresented: $showEndSheet) {
                EndSheetView(score: score, bestScore: $bestScore, restartAction: {
                    startGame()
                    showEndSheet = false
                })
            }
        }
    }

    // MARK: - Game logic

    func startGame() {
        score = 0
        timeRemaining = 60
        gameActive = true
        circleProgress = 1.0
        SoundManager.shared.startTick()
        prepareNextProblem()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            // update progress and every-second logic
            circleProgress = Double(timeRemaining) / 60.0
        }
        // second-level timer
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if timeRemaining > 0 && gameActive {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    endGame()
                }
            } else {
                t.invalidate()
            }
        }
    }

    func endGame() {
        gameActive = false
        timer?.invalidate()
        SoundManager.shared.stopTick()
        if score > bestScore {
            bestScore = score
        }
        // show end sheet summary
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showEndSheet = true
        }
    }

    func prepareNextProblem() {
        let num1 = Int.random(in: 1...12)
        let num2 = Int.random(in: 1...12)
        switch difficulty {
        case "Easy":
            correctAnswer = num1 + num2
            currentProblem = "\(num1) + \(num2) = ?"
        case "Medium":
            if Bool.random() {
                correctAnswer = num1 + num2
                currentProblem = "\(num1) + \(num2) = ?"
            } else {
                let a = max(num1, num2)
                let b = min(num1, num2)
                correctAnswer = a - b
                currentProblem = "\(a) - \(b) = ?"
            }
        case "Hard":
            if Bool.random() {
                correctAnswer = num1 * num2
                currentProblem = "\(num1) × \(num2) = ?"
            } else {
                let product = num1 * num2
                correctAnswer = num1
                currentProblem = "\(product) ÷ \(num2) = ?"
            }
        default:
            correctAnswer = num1 + num2
            currentProblem = "\(num1) + \(num2) = ?"
        }
        answer = ""
    }

    func checkAnswer() {
        guard gameActive else { return }
        if let userAnswer = Int(answer.trimmingCharacters(in: .whitespaces)), userAnswer == correctAnswer {
            score += 1
            SoundManager.shared.playCorrect()
        } else {
            SoundManager.shared.playWrong()
        }
        prepareNextProblem()
    }
}
