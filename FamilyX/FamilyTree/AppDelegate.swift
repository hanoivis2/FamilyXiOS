

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let splashScreen = SplashViewController()
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        window!.rootViewController = splashScreen
        window!.makeKeyAndVisible()
        
        return true
    }
    
    
    
}

