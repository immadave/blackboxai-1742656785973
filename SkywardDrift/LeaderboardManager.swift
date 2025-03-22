import Foundation

struct PlayerScore: Codable, Comparable {
    let playerName: String
    let score: Int
    let date: Date
    
    static func < (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        return lhs.score > rhs.score // Higher scores first
    }
}

class LeaderboardManager {
    static let shared = LeaderboardManager()
    private let userDefaults = UserDefaults.standard
    private let leaderboardKey = "skywardDrift.leaderboard"
    private let maxLeaderboardEntries = 10
    
    private var scores: [PlayerScore] = []
    
    private init() {
        loadScores()
        Logger.shared.log("LeaderboardManager initialized")
    }
    
    // MARK: - Score Management
    
    func submitScore(playerName: String, score: Int) {
        let newScore = PlayerScore(
            playerName: playerName,
            score: score,
            date: Date()
        )
        
        scores.append(newScore)
        scores.sort() // Sort by score (highest first)
        
        // Keep only top scores
        if scores.count > maxLeaderboardEntries {
            scores = Array(scores.prefix(maxLeaderboardEntries))
        }
        
        saveScores()
        Logger.shared.log("New score submitted - Player: \(playerName), Score: \(score)")
    }
    
    func getTopScores() -> [PlayerScore] {
        return scores
    }
    
    func getPlayerRank(score: Int) -> Int? {
        return scores.firstIndex { $0.score < score }.map { $0 + 1 }
    }
    
    func isHighScore(_ score: Int) -> Bool {
        return scores.count < maxLeaderboardEntries || score > (scores.last?.score ?? 0)
    }
    
    // MARK: - Persistence
    
    private func loadScores() {
        if let data = userDefaults.data(forKey: leaderboardKey),
           let decodedScores = try? JSONDecoder().decode([PlayerScore].self, from: data) {
            scores = decodedScores
            Logger.shared.log("Leaderboard loaded - \(scores.count) entries")
        }
    }
    
    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(scores) {
            userDefaults.set(encoded, forKey: leaderboardKey)
            Logger.shared.log("Leaderboard saved")
        }
    }
    
    // MARK: - Utility Methods
    
    func clearLeaderboard() {
        scores.removeAll()
        saveScores()
        Logger.shared.log("Leaderboard cleared")
    }
    
    func formatScore(_ score: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - LeaderboardView UI Components

import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var scores: [PlayerScore] = []
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.05, green: 0.05, blue: 0.15)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Title
                    Text("LEADERBOARD")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Scores List
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(Array(scores.enumerated()), id: \.element.date) { index, score in
                                LeaderboardRow(
                                    rank: index + 1,
                                    playerName: score.playerName,
                                    score: score.score,
                                    date: score.date
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title)
                },
                trailing: Button(action: {
                    showingClearConfirmation = true
                }) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.white)
                        .font(.title)
                }
            )
            .alert(isPresented: $showingClearConfirmation) {
                Alert(
                    title: Text("Clear Leaderboard"),
                    message: Text("Are you sure you want to clear all scores? This cannot be undone."),
                    primaryButton: .destructive(Text("Clear")) {
                        LeaderboardManager.shared.clearLeaderboard()
                        updateScores()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            updateScores()
        }
    }
    
    private func updateScores() {
        scores = LeaderboardManager.shared.getTopScores()
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let playerName: String
    let score: Int
    let date: Date
    
    var body: some View {
        HStack {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(rankColor)
                .frame(width: 60)
            
            VStack(alignment: .leading) {
                // Player Name
                Text(playerName)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                // Date
                Text(LeaderboardManager.shared.formatDate(date))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Score
            Text(LeaderboardManager.shared.formatScore(score))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color.yellow // Gold
        case 2: return Color.gray // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return Color.white
        }
    }
}