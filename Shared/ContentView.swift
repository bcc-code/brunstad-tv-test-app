//
//  ContentView.swift
//  Shared
//
//  Created by Matjaz Debelak on 02/12/2021.
//

import SwiftUI
import Foundation
import AVFoundation


struct ContentView: View {
    var body: some View {
        pl.onAppear(){
            let t = authenticate()
            let u = getUrl(accessToken: t)
            pl.player.replaceCurrentItem(with: AVPlayerItem.init(url: URL.init(string: u)!))
            pl.player.play()
        }
    }
    
    var authedUrl : String = "";
    let pl : Player = Player()
    
    private func getUrl(accessToken: String) -> String {
        let link = Config.StreamLink
        
        let headers = ["Authorization": "Bearer " + accessToken]
        let request = NSMutableURLRequest(url: NSURL(string: link)! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let sem = DispatchSemaphore.init(value: 0)
        var url = ""
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            defer { sem.signal() }
            if let error = error {
                print(error)
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options:[])
                if let m = responseJSON as? [String: Any] {
                    if let t = m["url"] as? String {
                        url = t
                    }
                }
                
            }
        })
        dataTask.resume()
        sem.wait()
        return url
    }

    private func authenticate() -> String {
        let sem = DispatchSemaphore.init(value: 0)
        
        let headers = ["content-type": "application/x-www-form-urlencoded"]

        let postData = NSMutableData(data: "grant_type=password".data(using: String.Encoding.utf8)!)
        postData.append("&username=\(Config.Username)".data(using: String.Encoding.utf8)!)
        postData.append("&password=\(Config.Password)".data(using: String.Encoding.utf8)!)
        postData.append("&audience=\(Config.Audience)".data(using: String.Encoding.utf8)!)
        postData.append("&scope=oauth,profile".data(using: String.Encoding.utf8)!)
        postData.append("&client_id=\(Config.ClientID)".data(using: String.Encoding.utf8)!)
        postData.append("&client_secret=\(Config.ClientSecret)".data(using: String.Encoding.utf8)!)

        let request = NSMutableURLRequest(url: NSURL(string: "https://login.bcc.no/oauth/token")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
var tok = ""
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            defer { sem.signal() }
            if let error = error {
                print(error)
                return
            }
            
            if let response = response as? HTTPURLResponse{
                print(response)
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options:[])
                if let m = responseJSON as? [String: Any] {
                    if let t = m["access_token"] as? String {
                        tok = t
                    }
                }
                
            }
        })

        dataTask.resume()
        sem.wait()
        return tok
    }
}
