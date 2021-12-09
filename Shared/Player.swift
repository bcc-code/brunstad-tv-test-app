//
//  Player.swift
//  Stream Test
//
//  Created by Matjaz Debelak on 02/12/2021.
//

import SwiftUI
import AVKit
import AVFoundation
#if !os(tvOS)
import NotificationCenter
#endif
import Foundation

struct Player: View {
    init() {

    }
    var token : String = ""

    var player = AVPlayer(url: URL(string: "https://devstreaming-cdn.apple.com/visdeos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    
    func toggleMute() {
        player.isMuted = !player.isMuted
    }
    
    func itemStatusCallback(p: AVPlayerItem, c: NSKeyValueObservedChange<AVPlayerItem.Status>) {
        updateItemStatus()
    }
    
    func updateItemStatus() {
        switch (player.currentItem?.status) {
        case .readyToPlay:
            itemStatus = "Ready To Play"
            break
        case .failed:
            itemStatus = "Failed"
            break
        case .none:
            itemStatus = "None"
            break
        default:
        itemStatus = "Unknown"
        }
    }
    
    func itemCallback(p: AVPlayer, c: NSKeyValueObservedChange<AVPlayerItem?>) {
        itemStatusObserver = c.newValue!!.observe(\.status, changeHandler: itemStatusCallback)
        player.currentItem?.preferredMaximumResolution = CGSize(width: 1920, height: 1080)
#if !os(tvOS)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemPlaybackStalled, object: p.currentItem, queue: .main, using: onStalled)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: p.currentItem, queue: .main, using: showErrorLog)
#endif
        
        print("Observing item")
    }
    func onStalled(n: Notification) {
        itemStatus = "Stalled"
    }
    
    @State var observer : NSKeyValueObservation!
    @State var observer2 : NSKeyValueObservation!
    @State var itemObserver : NSKeyValueObservation!
    @State var itemStatusObserver : NSKeyValueObservation!
    @State var averageBW = ""
    @State var timeControl = ""
    @State var reasonForWaitingToPlay = ""
    @State var itemStatus = ""
    @State var playerStatus = ""
    @State var error = ""
    @State var videoSize = ""
    @State var watched = ""
    @State var subsLang = ""
    @State var audioLang = ""
    
    func playerStatusCallback(p: AVPlayer, s: NSKeyValueObservedChange<AVPlayer.Status>) {
        switch player.status {
        case .failed:
            playerStatus = "Failed"
            break
        case .readyToPlay:
            playerStatus = "Ready"
            break
        default:
            playerStatus = ""
        }

    }
    
    func playerAppears() {
        observer =  player.observe(\.timeControlStatus, options: [.new, .old], changeHandler: obs)
        observer2 =  player.observe(\.status, options: [.new, .old], changeHandler: playerStatusCallback)
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: .main, using: periodic)
        itemObserver = player.observe(\.currentItem, options: [.initial, .new], changeHandler: itemCallback)
        
        player.play()
    }
    
    func periodic(t: CMTime) {
        let asset = player.currentItem!.asset
        for ch in asset.availableMediaCharacteristicsWithMediaSelectionOptions {
           
            var chType = ""
            if ch == .audible {
                chType = "Audio"
            } else if ch == .legible {
                chType = "Subs"
            } else {
                continue
            }
            
            if let g = asset.mediaSelectionGroup(forMediaCharacteristic: ch){
                let aa = player.currentItem?.currentMediaSelection.selectedMediaOption(in: g)
                if aa == nil {
                    continue
                }
                
                if chType == "Subs" {
                    subsLang = aa!.displayName
                }
                
                if chType == "Audio" {
                    audioLang = aa!.displayName
                }
            }
        }
            self.player.currentItem?.accessLog()?.events.forEach({ l in
                //print(l.averageAudioBitrate, l.averageVideoBitrate, l.downloadOverdue, l.durationWatched, l.transferDuration)
                averageBW = String(format: "%.2f Mbps",  l.averageVideoBitrate/1024/1024)
                watched = String(format: "%.0fs",  l.durationWatched)
            })
        
           updateItemStatus()
            switch(self.player.reasonForWaitingToPlay) {
            case AVPlayer.WaitingReason.evaluatingBufferingRate:
                reasonForWaitingToPlay = "Evaluating Buffering Rate"
                break;
            case AVPlayer.WaitingReason.noItemToPlay:
                reasonForWaitingToPlay = "No items to play"
                break;
            case AVPlayer.WaitingReason.toMinimizeStalls:
                reasonForWaitingToPlay = "Minimizing stalls (Buffering)"
                break;
            case nil:
                reasonForWaitingToPlay = "Playing"
            default:
                reasonForWaitingToPlay = self.player.reasonForWaitingToPlay.debugDescription
            }
        
        player.currentItem!.tracks.forEach { t in
            if t.assetTrack?.mediaType == .video {
                videoSize = String(format: "%.0fx%.0f@%.0f", t.assetTrack!.naturalSize.width, t.assetTrack!.naturalSize.height, t.currentVideoFrameRate)
            }
        }
    }
    
    func showErrorLog(n : Notification) {
        let errorEvents = self.player.currentItem?.errorLog()?.events
        let lastError = errorEvents?.last
        if lastError == nil {
            return
        }
        
        let domain : String = lastError!.errorDomain
        let status : String = String(format: "%d", lastError!.errorStatusCode)
        let comment : String = lastError!.errorComment == nil ? lastError!.errorComment! : ""
        
        error = String(format: "%@ %@ %@", domain, status, comment)
    }
    
    func obs(p: AVPlayer, c: NSKeyValueObservedChange<AVPlayer.TimeControlStatus>) {
        switch (player.timeControlStatus) {
        case .paused:
            timeControl = "Paused"
            break
        case .waitingToPlayAtSpecifiedRate:
            timeControl = "Waiting to play"
            break
        case .playing:
            timeControl = "Playing"
            break
        default:
            timeControl = ""
        }
    }
    
    func changeLanguage() {
        if let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let locale = Locale(identifier: "pl_PL")
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                player.currentItem?.select(option, in: group)
            }
        }
        
        if let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .audible) {
            let locale = Locale(identifier: "de_DE")
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                player.currentItem?.select(option, in: group)
            }
        }
    }
    
    let fontSize = 15.0
    let padding = 3.0
    var body: some View {
        VStack{
            VideoPlayer(player: player).onAppear(perform: playerAppears)
            HStack(spacing: 20.0){
                VStack{
                    Text("TimeControl Status").foregroundColor(.white)
                    Text(timeControl)
                        .accessibilityIdentifier("TimeControlValue")
                }.foregroundColor(Color.red)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.red, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                    .font(.system(size: fontSize))
                
                VStack{
                    Text("Waiting reason").foregroundColor(.white)
                    Text(reasonForWaitingToPlay)
                }.foregroundColor(Color.red)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.red, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                    .font(.system(size: fontSize))
                
                VStack{
                    Text("Item Status").foregroundColor(.white)
                    Text(itemStatus)
                }.foregroundColor(Color.green)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.green, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                    .font(.system(size: fontSize))
                
                VStack{
                    Text("Player Status").foregroundColor(.white)
                    Text(playerStatus)
                }.foregroundColor(Color.yellow)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.yellow, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                    .font(.system(size: fontSize))
                
                VStack{
                    Text("Video Status").foregroundColor(.white)
                    Text(videoSize)
                        .accessibilityIdentifier("VideoStatus")
                }.foregroundColor(Color.gray)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.gray, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                    .font(.system(size: fontSize))
                
                VStack{
                    Text("Video BW").foregroundColor(.white)
                    Text(averageBW)
                }.foregroundColor(Color.purple)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.purple, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                    .font(.system(size: fontSize))
                
                VStack{
                    Text("Stable time").foregroundColor(.white)
                    Text(watched)
                }.foregroundColor(Color.purple)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.purple, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                
                    .font(.system(size: fontSize))
                VStack{
                    Text("Subs").foregroundColor(.white)
                    Text(subsLang)
                        .accessibilityIdentifier("SubLanguage")
                    
                }.foregroundColor(Color.blue)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.blue, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                
                    .font(.system(size: fontSize))
                
                VStack{
                    Text("Audio").foregroundColor(.white)
                    Text(audioLang)
                        .accessibilityIdentifier("AudioLanguage")
                }.foregroundColor(Color.blue)
                    .padding(.all, padding)
#if !os(macOS)
                    .border(.blue, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
#endif
                    .font(.system(size: fontSize))
                
            }
        Text(error)
            Button("Change Language", action: changeLanguage)
                .accessibilityIdentifier("ChangeLanguage")

        }
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.black/*@END_MENU_TOKEN@*/)
    }
}

struct Player_Previews: PreviewProvider {
    static var previews: some View {
        Player()
    }
}
