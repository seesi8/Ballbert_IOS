//
//  Toggle.swift
//  Ballbert_IOS
//
//  Created by Sam Liebert on 12/4/23.
//

import Foundation
import SwiftUI

struct SymbolToggleStyle: ToggleStyle {
 
    var onImage: String = "mic.fill"
    var offImage: String = "keyboard.fill"
    var activeColor: Color = Color.green.opacity(0.4)
    var leftColor: Color = .teal
    var rightColor: Color = .green

 
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
 
            Spacer()
 
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.systemGray3))
                .overlay {
                    Circle()
                        .fill(.white)
                        .padding(3)
                        .overlay {
                        }
                        .offset(x: configuration.isOn ? 58 : -58)
                    
                    Image(systemName: offImage)
                        .foregroundColor(leftColor)
                        .offset(x: -58)
                        .zIndex(2)

                    
                    Image(systemName: onImage)
                        .foregroundColor(rightColor)
                        .offset(x: 58)
                        .zIndex(2)


                }
                .frame(width: 180, height: 64)
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
                .font(.system(size: 40))
        }
    }
}
