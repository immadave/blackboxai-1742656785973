import SwiftUI

// Settings storage keys
private enum SettingsKeys {
    static let soundEnabled = "soundEnabled"
    static let musicVolume = "musicVolume"
    static let sfxVolume = "sfxVolume"
    static let controlSensitivity = "controlSensitivity"
    static let graphicsQuality = "graphicsQuality"
    static let playerName = "playerName"
}

class GameSettings: ObservableObject {
    static let shared = GameSettings()
    private let defaults = UserDefaults.standard
    
    @Published var soundEnabled: Bool {
        didSet {
            defaults.set(soundEnabled, forKey: SettingsKeys.soundEnabled)
            Logger.shared.log("Sound enabled setting changed to: \(soundEnabled)")
        }
    }
    
    @Published var musicVolume: Double {
        didSet {
            defaults.set(musicVolume, forKey: SettingsKeys.musicVolume)
            Logger.shared.log("Music volume changed to: \(musicVolume)")
        }
    }
    
    @Published var sfxVolume: Double {
        didSet {
            defaults.set(sfxVolume, forKey: SettingsKeys.sfxVolume)
            Logger.shared.log("SFX volume changed to: \(sfxVolume)")
        }
    }
    
    @Published var controlSensitivity: Double {
        didSet {
            defaults.set(controlSensitivity, forKey: SettingsKeys.controlSensitivity)
            Logger.shared.log("Control sensitivity changed to: \(controlSensitivity)")
        }
    }
    
    @Published var graphicsQuality: GraphicsQuality {
        didSet {
            defaults.set(graphicsQuality.rawValue, forKey: SettingsKeys.graphicsQuality)
            Logger.shared.log("Graphics quality changed to: \(graphicsQuality.rawValue)")
        }
    }
    
    @Published var playerName: String {
        didSet {
            defaults.set(playerName, forKey: SettingsKeys.playerName)
            Logger.shared.log("Player name changed to: \(playerName)")
        }
    }
    
    private init() {
        // Load saved settings or use defaults
        soundEnabled = defaults.bool(forKey: SettingsKeys.soundEnabled, defaultValue: true)
        musicVolume = defaults.double(forKey: SettingsKeys.musicVolume, defaultValue: 0.7)
        sfxVolume = defaults.double(forKey: SettingsKeys.sfxVolume, defaultValue: 0.8)
        controlSensitivity = defaults.double(forKey: SettingsKeys.controlSensitivity, defaultValue: 0.5)
        graphicsQuality = GraphicsQuality(rawValue: defaults.string(forKey: SettingsKeys.graphicsQuality) ?? "") ?? .high
        playerName = defaults.string(forKey: SettingsKeys.playerName) ?? "Player"
        
        Logger.shared.log("GameSettings initialized")
    }
    
    func resetToDefaults() {
        soundEnabled = true
        musicVolume = 0.7
        sfxVolume = 0.8
        controlSensitivity = 0.5
        graphicsQuality = .high
        playerName = "Player"
        Logger.shared.log("Settings reset to defaults")
    }
}

enum GraphicsQuality: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var settings = GameSettings.shared
    @State private var showingResetConfirmation = false
    
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Player Settings Section
                        SettingsSection(title: "PLAYER") {
                            VStack(spacing: 20) {
                                // Player Name
                                CustomTextField(
                                    title: "Player Name",
                                    text: $settings.playerName
                                )
                            }
                        }
                        
                        // Audio Settings Section
                        SettingsSection(title: "AUDIO") {
                            VStack(spacing: 20) {
                                // Sound Toggle
                                Toggle("Sound Enabled", isOn: $settings.soundEnabled)
                                    .toggleStyle(NeonToggleStyle())
                                
                                // Music Volume
                                CustomSlider(
                                    title: "Music Volume",
                                    value: $settings.musicVolume
                                )
                                
                                // SFX Volume
                                CustomSlider(
                                    title: "SFX Volume",
                                    value: $settings.sfxVolume
                                )
                            }
                        }
                        
                        // Controls Settings Section
                        SettingsSection(title: "CONTROLS") {
                            CustomSlider(
                                title: "Control Sensitivity",
                                value: $settings.controlSensitivity
                            )
                        }
                        
                        // Graphics Settings Section
                        SettingsSection(title: "GRAPHICS") {
                            Picker("Quality", selection: $settings.graphicsQuality) {
                                ForEach(GraphicsQuality.allCases, id: \.self) { quality in
                                    Text(quality.rawValue)
                                        .tag(quality)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Reset Button
                        Button(action: {
                            showingResetConfirmation = true
                        }) {
                            Text("Reset to Defaults")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title)
                }
            )
            .alert(isPresented: $showingResetConfirmation) {
                Alert(
                    title: Text("Reset Settings"),
                    message: Text("Are you sure you want to reset all settings to their default values?"),
                    primaryButton: .destructive(Text("Reset")) {
                        settings.resetToDefaults()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// MARK: - Custom UI Components

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            content
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
        }
    }
}

struct CustomSlider: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Slider(value: $value)
                .accentColor(Color(red: 0.3, green: 0.6, blue: 1.0))
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16, design: .rounded))
        }
    }
}

struct NeonToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ?
                      Color(red: 0.3, green: 0.6, blue: 1.0) :
                        Color(red: 0.3, green: 0.3, blue: 0.3))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .animation(.spring(), value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        return object(forKey: key) as? Bool ?? defaultValue
    }
    
    func double(forKey key: String, defaultValue: Double) -> Double {
        return object(forKey: key) as? Double ?? defaultValue
    }
}