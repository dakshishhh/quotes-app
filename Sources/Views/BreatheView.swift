import SwiftUI
import UIKit
import AVFoundation

class BreathingAudioService {
    static let shared = BreathingAudioService()
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    
    private var currentPhase: Double = 0
    private var frequency: Double = 432.0
    private var amplitude: Double = 0.0
    private var sampleRate: Double = 44100.0
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.duckOthers, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        setupEngine()
    }
    
    private func setupEngine() {
        let format = engine.outputNode.inputFormat(forBus: 0)
        sampleRate = format.sampleRate > 0 ? format.sampleRate : 44100.0
        
        let source = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                // Smooth exponential decay for a "chime/bell" envelope
                if self.amplitude > 0.0001 {
                    self.amplitude *= 0.99996 // Decays over a few seconds
                } else {
                    self.amplitude = 0
                }
                
                // Pure sine wave
                let val = sin(self.currentPhase) * self.amplitude * 0.15 // 0.15 max volume to keep it very soft and Zen
                
                self.currentPhase += (2.0 * .pi * self.frequency) / self.sampleRate
                if self.currentPhase > 2.0 * .pi {
                    self.currentPhase -= 2.0 * .pi
                }
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = Float(val)
                }
            }
            return noErr
        }
        
        self.sourceNode = source
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Engine start error: \(error)")
        }
    }
    
    func speak(_ text: String) {
        // We repurpose the "speak" method to play the chime based on the phase
        switch text {
        case "Inhale":
            frequency = 528.0 // "Miracle" frequency (higher)
        case "Hold":
            frequency = 432.0 // "Healing" frequency (middle)
        case "Exhale":
            frequency = 396.0 // "Liberating" frequency (lower)
        default:
            frequency = 432.0
        }
        
        // Reset phase to prevent popping, punch amplitude to 1.0 to strike the "bell"
        currentPhase = 0
        amplitude = 1.0
    }
    
    func stop() {
        amplitude = 0.0
    }
}

struct BreatheView: View {
    @State private var isBreathing = false
    @State private var phase: BreathePhase = .inhale
    @State private var currentSet = 1
    @State private var totalSets = 3 // Default
    
    // Animation states
    @State private var circleScale: CGFloat = 0.5
    @State private var progressRingOffset: CGFloat = 1.0 // 1.0 is full dashoffset (empty), 0.0 is drawn
    
    enum BreathePhase {
        case inhale
        case hold1
        case exhale
        case hold2
        
        var displayText: String {
            switch self {
            case .inhale: return "Inhale"
            case .hold1, .hold2: return "Hold"
            case .exhale: return "Exhale"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if !isBreathing {
                // Setup View
                VStack(spacing: 40) {
                    Text("Box Breathing")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        Text("SETS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(2)
                        
                        HStack(spacing: 24) {
                            Button(action: { if totalSets > 1 { totalSets -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            
                            Text("\(totalSets)")
                                .font(.system(size: 64, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 80)
                            
                            Button(action: { if totalSets < 5 { totalSets += 1 } }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                        }
                    }
                    
                    Button(action: startBreathing) {
                        Text("Begin")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 200)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
            } else {
                // Breathing Animation View
                VStack {
                    HStack {
                        Button(action: stopBreathing) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    Text("\(currentSet) of \(totalSets)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(2)
                        .padding(.bottom, 60)
                    
                    ZStack {
                        // The animated circle
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .scaleEffect(circleScale)
                        
                        // The progress ring (only visible during holds)
                        if phase == .hold1 || phase == .hold2 {
                            Circle()
                                .trim(from: 0, to: 1.0 - progressRingOffset)
                                .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 300 * circleScale, height: 300 * circleScale)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                    
                    Text(phase.displayText)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(2)
                        .padding(.top, 60)
                        .animation(nil, value: phase)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func startBreathing() {
        UIApplication.shared.isIdleTimerDisabled = true
        AppState.shared.hideTabBar = true
        isBreathing = true
        currentSet = 1
        circleScale = 0.5
        runPhase(.inhale)
    }
    
    private func stopBreathing() {
        UIApplication.shared.isIdleTimerDisabled = false
        AppState.shared.hideTabBar = false
        isBreathing = false
        BreathingAudioService.shared.stop()
    }
    
    private func runPhase(_ newPhase: BreathePhase) {
        guard isBreathing else { return }
        phase = newPhase
        
        let duration: TimeInterval = 4.0
        BreathingAudioService.shared.speak(phase.displayText)
        
        switch phase {
        case .inhale:
            progressRingOffset = 1.0
            withAnimation(.linear(duration: duration)) {
                circleScale = 1.0
            }
            
        case .hold1:
            progressRingOffset = 1.0
            withAnimation(.linear(duration: duration)) {
                progressRingOffset = 0.0
            }
            
        case .exhale:
            progressRingOffset = 1.0
            withAnimation(.linear(duration: duration)) {
                circleScale = 0.5
            }
            
        case .hold2:
            progressRingOffset = 1.0
            withAnimation(.linear(duration: duration)) {
                progressRingOffset = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            guard isBreathing else { return }
            
            switch phase {
            case .inhale: runPhase(.hold1)
            case .hold1: runPhase(.exhale)
            case .exhale: runPhase(.hold2)
            case .hold2:
                if currentSet < totalSets {
                    currentSet += 1
                    runPhase(.inhale)
                } else {
                    stopBreathing()
                }
            }
        }
    }
}
