import SwiftUI

struct SettingsView: View {
    @State private var uid: String = ""
    @State private var speak: Bool = false
    @State private var defaultToSpeech: Bool = false

    // Add a state variable to store the selected color scheme
    @State var selectedColorScheme: Int = UserDefaults.standard.integer(forKey: "color_scheme")

    @State var showsAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Device Connection")) {
                TextField("Device UID", text: $uid)
                    .onChange(of: uid) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "device_uid")
                    }
            }
            
            Section(header: Text("App Preferences")) {
                Toggle(isOn: $speak, label: {
                    Text("Read Aloud")
                })
                .onChange(of: speak) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "speak")
                }
                Toggle(isOn: $defaultToSpeech, label: {
                    Text("Default to speech when opening app.")
                })
                .onChange(of: defaultToSpeech) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "defaultToSpeech")
                }
            }

            // Add a new section for color scheme selection
            Section(header: Text("Color Scheme")) {
                Picker("Select Color Scheme", selection: $selectedColorScheme) {
                    Text("Dark").tag(0)
                    Text("Light").tag(1)
                    Text("System").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedColorScheme) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "color_scheme")
                    self.showsAlert = true
                }
                .alert(isPresented: self.$showsAlert) {
                    Alert(title: Text("Restart app to take effect."))
                }
            }
        }
        .onAppear {
            if let savedUid = UserDefaults.standard.string(forKey: "device_uid") {
                uid = savedUid
            }
            speak = UserDefaults.standard.bool(forKey: "speak")
            defaultToSpeech = UserDefaults.standard.bool(forKey: "defaultToSpeech")

        }
        .preferredColorScheme(colorScheme)
    }


    // Helper function to get the color scheme based on the selected value
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
