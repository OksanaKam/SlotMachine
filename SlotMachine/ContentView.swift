//
//  SwiftUIView.swift
//  SlotMachine
//
//  Created by Оксана Каменчук on 04.04.2023.
//

import SwiftUI
import Combine

class GamesModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let arrayEmoji = ["🍒", "🍏", "🍋", "🍹", "🍭"]
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init() {
        timer
            .receive(on: RunLoop.main)
            .sink { _ in self.random() }
            .store(in: &cancellables)
        
        $run
            .receive(on: RunLoop.main)
            .map {
                guard !$0 && self.startGame else {return "Начинаем играть!"}
                return self.emoji1 == self.emoji2 && self.emoji1 == self.emoji3 ? "Поздравляем, Вы победили!" : "Попробуйте еще раз!"
            }
            .assign(to: \.textTitle, on: self)
            .store(in: &cancellables)
        
        $run
            .receive(on: RunLoop.main)
            .map { $0 == true ? "🔴" : "🔵" }
            .assign(to: \.buttonText, on: self)
            .store(in: &cancellables)
    }
    private func random() {
        guard run else {return}
        emoji1 = arrayEmoji.randomElement() ?? ""
        emoji2 = arrayEmoji.randomElement() ?? ""
        emoji3 = arrayEmoji.randomElement() ?? ""
    }
    
    @Published var run: Bool = false
    @Published var startGame = false
    
    @Published var emoji1: String = "🍎"
    @Published var emoji2: String = "🍎"
    @Published var emoji3: String = "🍎"
    @Published var textTitle = ""
    @Published var buttonText = ""
        
}

struct Slot <Content: View>: View {
    var content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    
    var body: some View {
        content()
            .font(.system(size: 80))
            .animation(.easeIn(duration: 1.5))
            .id(UUID())
    }
}

struct ContentView: View {
    @ObservedObject private var game = GamesModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { forms in
                    Image("theme")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: forms.size.width, height: forms.size.height)
                   
                   
    }
                VStack {
                    Spacer()
                    Text(game.textTitle)
                        .font(.system(size: 35))
                    Spacer()
                    
                    HStack {
                        Slot { Text(game.emoji1) }
                        Slot { Text(game.emoji2) }
                        Slot { Text(game.emoji3) }
                    }
                    Spacer()
                    Button(action: {game.run.toggle(); game.startGame = true}, label: {
                        Text(game.buttonText)
                    })
                        .font(.system(size: 70))
                }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
