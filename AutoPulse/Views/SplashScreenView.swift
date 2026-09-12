import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var ringProgress = 0.0
    @State private var showTagline = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Animated ring with logo
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .stroke(AppTheme.accent.opacity(0.1), lineWidth: 2)
                            .frame(width: 160, height: 160)

                        // Animated progress ring
                        Circle()
                            .trim(from: 0, to: ringProgress)
                            .stroke(
                                AppTheme.accent,
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))

                        // Logo container
                        ZStack {
                            Circle()
                                .fill(AppTheme.backgroundCard)
                                .frame(width: 130, height: 130)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                                )

                            Image("vehicle_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                        }
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)

                    // App name
                    VStack(spacing: 8) {
                        Text("AutoPulse")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .opacity(opacity)

                        if showTagline {
                            Text(String(localized: "Smart Vehicle Platform"))
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }

                    Spacer()

                    // Loading indicator
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(AppTheme.accent)
                            .opacity(opacity)
                        Text(String(localized: "Loading..."))
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .opacity(opacity)
                    }
                    .padding(.bottom, 48)
                }
            }
            .onAppear {
                // Fade in and scale up
                withAnimation(.easeOut(duration: 0.6)) {
                    opacity = 1.0
                    scale = 1.0
                }

                // Animate ring
                withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                    ringProgress = 1.0
                }

                // Show tagline
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        showTagline = true
                    }
                }

                // Navigate to main app
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}
