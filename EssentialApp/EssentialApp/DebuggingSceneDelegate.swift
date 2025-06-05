//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Evgenii Iavorovich on 6/5/25.
//

import EssentialFeed
import UIKit

#if DEBUG
class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeHttpClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        
        return super.makeHttpClient()
    }
    
    
    private class AlwaysFailingHTTPClient: HTTPClient {
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any HTTPClientTask {
            completion(.failure(NSError(domain: "offline", code: 0)))
            return Task()
        }
        
    }
}
#endif
