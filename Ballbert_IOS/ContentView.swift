//
//  ContentView.swift
//  Ballbert_IOS
//
//  Created by Sam Liebert on 12/1/23.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var websocket = Websocket()
    @State var input = "";
    @State private var isToggled = UserDefaults.standard.bool(forKey: "defaultToSpeech")
    @State private var selectedColorPreferance = 0
    @FocusState private var fieldFocused: Bool
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    private var colorScheme: ColorScheme? {
        switch UserDefaults.standard.integer(forKey: "color_scheme") {
        case 0:
            return .dark
        case 1:
            return .light
        case 2:
            return nil
        default:
            return nil
        }
    }
    
    func runTranscribe(){
        if !isRecording {
            speechRecognizer.transcribe()
        } else {
            speechRecognizer.stopTranscribing()
            
            if speechRecognizer.transcript == "" {
                return
            }
            
            if UserDefaults.standard.bool(forKey: "speak"){
                websocket.sendJsonMessage("handle_text", [
                    "transcript": speechRecognizer.transcript], isUserMessage: true)
            } else{
                websocket.sendJsonMessage("handle_text_to_text", [
                    "transcript": speechRecognizer.transcript], isUserMessage: true)
            }
            
        }
        
        isRecording.toggle()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isToggled{
                    Text("Transcript: \(speechRecognizer.transcript)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.background)
                }
                List(websocket.messages) { message in
                    if message.type == "chunk"{
                        Text((message.kwargs["chunk"] as? String) ?? "")
                    }
                    else if message.type == "user"{
                        Text((message.kwargs["transcript"] as? String) ?? "User")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .background(.background)
                Spacer()
                if isToggled {
                    ZStack{
                        Button(action: {
                            runTranscribe()
                        }, label: {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 70))
                                .zIndex(1)
                                .foregroundColor(isRecording ? .red : .blue)
                        })
                        .onAppear(){
                            runTranscribe()
                        }
                        .background{
                            if isToggled{
                                Circle()
                                    .fill(Color(.systemGray3))
                                    .padding(3)
                                    .overlay {
                                    }
                                    .frame(width: 100, height: 100)
                                    .zIndex(-1)
                            }
                        }
                        .zIndex(1)
                        .offset(y: -10)
                        .frame(width: 80, height: 70)
                    }
                    .frame(height: 0)
                    .zIndex(1)

                } else {
                    HStack{
                        TextField("Enter your query...", text: $input)
                            .padding(5.0)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                            .padding()
                            .font(.system(size: 20))
                            .focused($fieldFocused)
                        Button(action: {
                            if UserDefaults.standard.bool(forKey: "speak"){
                                websocket.sendJsonMessage("handle_text", [
                                    "transcript": input], isUserMessage: true)
                            } else{
                                websocket.sendJsonMessage("handle_text_to_text", [
                                    "transcript": input], isUserMessage: true)
                            }
                            
                            input = ""
                            
                            fieldFocused = false
                            
                        }, label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 20, weight: .bold))

                        })
                        .padding(8.0)
                        .background(){
                            Circle()
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        }
                        .foregroundColor(.white)
                        .padding(.trailing, 20.0)
                    }

                }

                HStack {
                    Toggle(isOn: $isToggled) {
                    }
                    .padding(.trailing, 7.0)
                    .toggleStyle(SymbolToggleStyle())
                    .frame(width: 180)
                    .navigationBarTitle("Ballbert")
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button(action: {
                                
                            }, label: {
                                NavigationLink {
                                    SettingsView()
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                }
                            })
                        
                        }
                    }
                }
            }
            .background(.background)
            .preferredColorScheme(colorScheme)
        }
        .background(.background)

    }

    
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

