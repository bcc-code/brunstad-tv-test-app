//
//  Stream_TestApp.swift
//  Shared
//
//  Created by Matjaz Debelak on 02/12/2021.
//

import SwiftUI
import Rudder

@main
struct Stream_TestApp: App {
    
    init() {
        let builder = RSConfigBuilder().withDataPlaneURL(URL.init(string: Config.RudderstackURL)!)
        RSClient.getInstance(Config.RudderstackID, config: builder.build())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
