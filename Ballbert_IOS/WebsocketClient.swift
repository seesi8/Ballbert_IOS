//
//  WebsocketClient.swift
//  Ballbert_IOS
//
//  Created by Sam Liebert on 12/4/23.
//

import Foundation

struct Websocket_Message : Hashable, Identifiable {
    var id: Date { time }  // Using the 'type' property as the id

    static func == (lhs: Websocket_Message, rhs: Websocket_Message) -> Bool {
        let strDictionary1 = lhs.kwargs.mapValues { $0 as? String ?? "" }
        let strDictionary2 = rhs.kwargs.mapValues { $0 as? String ?? "" }

        return lhs.type == rhs.type && strDictionary1 == strDictionary2 && lhs.time == rhs.time
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(time)
    }
    
    var type: String
    var kwargs: Dictionary<String, Any>
    var time: Date
    var isUserMessage: Bool  // Added property
    
    init(type: String, kwargs: [String: Any], isUserMessage: Bool = false) {
        self.type = type
        self.kwargs = kwargs
        self.time = Date()
        self.isUserMessage = isUserMessage
    }
}


class Websocket: ObservableObject {
    @Published var messages = [Websocket_Message]()
    let audioPlayer = AudioPlayer()
    private var webSocketTask: URLSessionWebSocketTask?
    
    init() {
        self.connect()
    }
    
    private func connect() {
        guard let url = URL(string: "wss://websocket.ballbert.com:8765") else { return }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        sendJsonMessage("Authentication", ["UID": UserDefaults.standard.string(forKey: "device_uid") ?? deviceIdentifier])
        receiveMessage()
    }
    
    var deviceIdentifier: String {
        if let storedIdentifier = UserDefaults.standard.string(forKey: "device_uid") {
            return storedIdentifier
        } else {
            let newIdentifier = UUID().uuidString
            UserDefaults.standard.set(newIdentifier, forKey: "device_uid")
            return newIdentifier
        }
    }
        
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            DispatchQueue.main.async { // Switch to the main thread
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let message):
                    switch message {
                    case .string(let text):
                        var dictionary = convertJSONToDictionary(text)
                        let type = (dictionary?["type"] ?? "") as! String
                        
                        dictionary?["type"] = nil
                        
                        let to_struct = Websocket_Message(type: type, kwargs: dictionary ?? ["type": type])
                        
                        // Check if the received message is a chunk or a user message
                        if type == "chunk" {
                            print("got chunk")
                            // Combine consecutive chunks
                            
                            var last_chunk = ""
                            var last_index = -1
                            var has_chunk = false
                            
                            
                            for (index, message) in self!.messages.reversed().enumerated(){
                                
                                
                                if message.type == "user"{
                                    break
                                }
                                
                                else if message.type == "chunk"{
                                    last_chunk = message.kwargs["chunk"] as? String ?? "Error"
                                    last_index = (self!.messages.count - 1) - index
                                    has_chunk = true
                                    break
                                }
                            }
                            
                            
                            
                            if has_chunk {
                                print("has chunk")
                                print(last_index, last_chunk)
                                self?.messages[last_index].kwargs["chunk"] = ((last_chunk) + (to_struct.kwargs["chunk"] as? String ?? "Error"))
                            } else {
                                self?.messages.append(to_struct)
                            }
                        } else if type == "audio" {
                            print("audio")
                            let to_struct = Websocket_Message(type: type, kwargs: dictionary ?? ["type": type])

                            let audioString = to_struct.kwargs["audio"] as? String ?? "Error"
                            
                            if !(self?.audioPlayer.isPlaying ?? false){
                                print("Started playback")
                                self?.audioPlayer.start_playback()
                            }
                                                        
                            self?.audioPlayer.add_to_queue(base64CompressedAudioData: audioString)
                        }
                        else {
                            print(type)
                            // Non-chunk message, add directly to the array
                            self?.messages.append(to_struct)
                        }
                        
                    case .data(_):
                        // Handle binary data
                        break
                    @unknown default:
                        break
                    }
                }
                self?.receiveMessage()
            }
        }
    }
    
   
    
    func sendJsonMessage(_ type: String, _ message: Dictionary<String, Any>, isUserMessage : Bool = false) {
        print(self.messages)
        var new_message = message
        new_message["type"] = type
        
        let jsonString = convertDictionaryToJSON(new_message)
        
        if jsonString != nil {
            DispatchQueue.main.async {
                print("adding")
                if isUserMessage {
                    let to_struct = Websocket_Message(type: "user", kwargs: new_message, isUserMessage: isUserMessage)
                    self.messages.append(to_struct)
                }
            }
            sendMessage(jsonString!)  // Pass isUserMessage as true for user messages
        }
    }
    
    func sendMessage(_ message: String) {
        
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("eror")
                print(error.localizedDescription)
            } else {
                print("succeeded")

            }
        }
    }
    
}
