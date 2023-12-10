//
//  Audio.swift
//  Ballbert_IOS
//
//  Created by Sam Liebert on 12/5/23.
//

import Foundation
import zlib
import Compression
import AVFoundation

class AudioPlayer {
    var audioPlayer: AVAudioPlayer?
    var queue: Array<String> = []
    var isPlaying = false
    
    
    func add_to_queue(base64CompressedAudioData: String){
        queue.append(base64CompressedAudioData)
    }

    func start_playback(){
        if self.isPlaying{
            return
        }
        
        self.isPlaying = true
        Task.detached() { [self] in
            while true{
                if !(self.audioPlayer?.isPlaying ?? false) && queue.first != nil{
                    if queue.first! == "stop!" && queue.count == 1{
                        print("stopped")
                        self.isPlaying = false
                        self.queue.removeFirst()
                        break
                    }
                    let first = self.queue.removeFirst()
                    self.play(base64CompressedAudioData: first)
                }
            }
        }
    }
        
    func play(base64CompressedAudioData: String) {
        // Convert base64 string to Data
        
        if(base64CompressedAudioData == "stop!"){
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        guard var compressedAudioData = Data(base64Encoded: base64CompressedAudioData) else {
            fatalError("Failed to decode base64 data")
//            return
        }

        compressedAudioData.removeFirst(2)

        let compressedData: NSData = compressedAudioData as NSData

        do {
            
            for byte in compressedData[0...10] {
                print(String(format: "%02X", byte), terminator: " ")
            }
            
            let decompressedData = try compressedData.decompressed(using: .zlib)
            
            // Now `decompressedData` contains the uncompressed audio data
            // Save the decompressed audio data to a file
            
            let audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_audio.raw")
            try decompressedData.write(to: audioURL)
            
            // Initialize the audio player with the data
            audioPlayer = try AVAudioPlayer(data: decompressedData as Data)
            
            // Prepare the audio player
            audioPlayer?.prepareToPlay()
            
            // Play the audio
            audioPlayer?.play()
            
            print("played")
            
        } catch {

            fatalError("Error decompressing data: \(error.localizedDescription)")
        }
    }
}

