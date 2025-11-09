import SwiftUI

@Observable
class GameModel {
    let choices = ["✊", "✋", "✌️"]
    
    // Game state
    var playerChoice = ""
    var computerChoice = ""
    var result = ""
    var currentStreak = 0

    
    var computerLevel = 0
    var playerLevel = 0
    var showResetMessage = false
    
    // MARK: - Game Logic
    func play(_ playerMove: String) {
        // Always run on the main thread so SwiftUI can animate changes
        DispatchQueue.main.async {
            self.playerChoice = playerMove
            self.computerChoice = self.choices.randomElement()!
            self.result = self.determineWinner(player: self.playerChoice, computer: self.computerChoice)
            self.updateLevels(for: self.result)
        }
    }
    
    func determineWinner(player: String, computer: String) -> String {
        let computerName = "EmMary"
        if player == computer {
            return "\(computerName) chose \(computerChoice). It’s a draw!"
        }
        
        switch (player, computer) {
        case ("✊", "✌️"), ("✋", "✊"), ("✌️", "✋"):
            return "\(computerName) chose \(computerChoice). You Win!"
        default:
            return "\(computerName) chose \(computerChoice). You lose :)))"
        }
    }
    
    func updateLevels(for result: String) {
        // Perform UI-impacting updates on main queue
        DispatchQueue.main.async {
            if result.contains("lose") {
                self.computerLevel = min(self.computerLevel + 1, 5)
                self.currentStreak = 0
            } else if result.contains("Win") {
                self.playerLevel = min(self.playerLevel + 1, 5)
                self.currentStreak += 1
            }
            
            // Reset when winner reaches 5
            if self.computerLevel == 5 || self.playerLevel == 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.resetGame()
                }
            }
        }
    }
    
    func resetGame() {
        DispatchQueue.main.async {
            self.showResetMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.computerLevel = 0
                self.playerLevel = 0
                self.showResetMessage = false
                self.result = ""
            }
        }
    }
}
