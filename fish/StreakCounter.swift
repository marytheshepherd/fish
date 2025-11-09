import Foundation

@Observable
class StreakCounter {
    private(set) var highestStreak: Int = 0

    func updateHighestStreak(currentStreak: Int) {
        // Only update if current streak beats the record
        if currentStreak > highestStreak {
            highestStreak = currentStreak
            saveHighestStreak()
        }
    }

    private func saveHighestStreak() {
        UserDefaults.standard.set(highestStreak, forKey: "highestStreak")
    }


}
//
//  StreakCounter.swift
//  fish
//
//  Created by Event on 9/11/25.
//

