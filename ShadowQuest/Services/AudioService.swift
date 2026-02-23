// AudioService.swift
// ShadowQuest
//
// Service audio — musique de fond et effets sonores
// Note: Les fichiers audio seront ajoutes dans Resources/Sounds/
// Pour l'instant le service est pret mais sans fichiers audio reels.

import Foundation
import AVFoundation

@Observable
final class AudioService {
    static let shared = AudioService()

    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?

    var musicVolume: Float = 0.5 {
        didSet { musicPlayer?.volume = musicVolume }
    }

    var sfxVolume: Float = 0.7
    var isMusicEnabled: Bool = true
    var isSFXEnabled: Bool = true

    private init() {}

    func playMusic(_ filename: String) {
        guard isMusicEnabled else { return }
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Boucle infinie
            musicPlayer?.volume = musicVolume
            musicPlayer?.play()
        } catch {
            // Fichier audio non trouve — silencieux
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func playSFX(_ filename: String) {
        guard isSFXEnabled else { return }
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = sfxVolume
            sfxPlayer?.play()
        } catch {
            // Fichier audio non trouve — silencieux
        }
    }

    func toggleMusic() {
        isMusicEnabled.toggle()
        if !isMusicEnabled { stopMusic() }
    }

    func toggleSFX() {
        isSFXEnabled.toggle()
    }
}
