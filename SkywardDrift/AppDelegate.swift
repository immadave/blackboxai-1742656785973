import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize logger
        Logger.shared.log("Application started", level: .info)
        
        // Create and configure the window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set the root view controller
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        return true
    }
}