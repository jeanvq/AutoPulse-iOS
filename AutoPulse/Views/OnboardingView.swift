import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "car.fill",
            title: "Welcome to AutoPulse",
            subtitle: "Your smart vehicle health platform",
            description: "Track your vehicles, fuel records, and maintenance all in one place.",
            color: AppTheme.accent
        ),
        OnboardingPage(
            icon: "gauge.high",
            title: "Health Score",
            subtitle: "Know your vehicle's condition",
            description: "Get a real-time health score based on your fuel and maintenance history.",
            color: AppTheme.warning
        ),
        OnboardingPage(
            icon: "cpu.fill",
            title: "AI Scanner",
            subtitle: "Diagnose warning lights instantly",
            description: "Take a photo of any dashboard warning light and get an AI-powered diagnosis in seconds.",
            color: AppTheme.success
        ),
        OnboardingPage(
            icon: "cloud.sun.fill",
            title: "Weather Alerts",
            subtitle: "Drive smarter every day",
            description: "Get personalized vehicle tips based on your local weather conditions.",
            color: AppTheme.info
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        hasSeenOnboarding = true
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding()
                }

                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? AppTheme.accent : AppTheme.textMuted)
                            .frame(width: currentPage == index ? 20 : 8, height: 8)
                            .clipShape(Capsule())
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // Button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasSeenOnboarding = true
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppTheme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 180, height: 180)
                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(page.color)
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.headline)
                    .foregroundStyle(page.color)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}
