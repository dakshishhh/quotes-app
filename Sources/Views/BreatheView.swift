import SwiftUI
import UIKit

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
    }
    
    private func runPhase(_ newPhase: BreathePhase) {
        guard isBreathing else { return }
        phase = newPhase
        
        let duration: TimeInterval = 4.0
        
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
