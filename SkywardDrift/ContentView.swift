import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var isShowingGame = false
    @State private var isShowingLeaderboard = false
    @State private var isShowingSettings = false
    
    var body: some View {
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
            
            // Content
            VStack(spacing: 30) {
                // Title
                Text("SKYWARD DRIFT")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.6), radius: 10, x: 0, y: 0)
                    .padding(.top, 50)
                
                Spacer()
                
                // Menu Buttons
                VStack(spacing: 20) {
                    MenuButton(title: "PLAY", action: {
                        isShowingGame = true
                        Logger.shared.log("User tapped Play button")
                    })
                    
                    MenuButton(title: "LEADERBOARD", action: {
                        isShowingLeaderboard = true
                        Logger.shared.log("User tapped Leaderboard button")
                    })
                    
                    MenuButton(title: "SETTINGS", action: {
                        isShowingSettings = true
                        Logger.shared.log("User tapped Settings button")
                    })
                }
                .padding(.bottom, 100)
            }
        }
        .fullScreenCover(isPresented: $isShowingGame) {
            GameView()
        }
        .sheet(isPresented: $isShowingLeaderboard) {
            LeaderboardView()
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 280, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.3, green: 0.6, blue: 1.0),
                                    Color(red: 0.2, green: 0.4, blue: 0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color(red: 0.3, green: 0.6, blue: 1.0).opacity(0.5), radius: 10, x: 0, y: 5)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// Placeholder Views
struct GameView: View {
    var body: some View {
        Text("Game View - Coming Soon")
            .onAppear {
                Logger.shared.log("Game View appeared")
            }
    }
}

struct LeaderboardView: View {
    var body: some View {
        Text("Leaderboard - Coming Soon")
            .onAppear {
                Logger.shared.log("Leaderboard View appeared")
            }
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings - Coming Soon")
            .onAppear {
                Logger.shared.log("Settings View appeared")
            }
    }
}

#Preview {
    ContentView()
}