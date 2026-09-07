import SwiftUI

// ──────────────────────────────────────────────────────────────────
// QuizView — 3-question multiple-choice quiz for each topic
// ──────────────────────────────────────────────────────────────────
struct QuizView: View {
    let questions: [QuizQuestion]
    let topicID: String
    let accentColor: Color

    @EnvironmentObject private var progressStore: ProgressStore
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var score = 0
    @State private var quizDone = false

    private var currentQuestion: QuizQuestion { questions[currentIndex] }

    var body: some View {
        if quizDone {
            QuizResultView(score: score, total: questions.count,
                           accentColor: accentColor) {
                resetQuiz()
            }
        } else {
            VStack(spacing: 0) {
                quizProgress
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        questionCard
                        answerGrid
                        if showResult { explanationCard }
                        nextButton
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Sub-views

    private var quizProgress: some View {
        HStack {
            Text("Question \(currentIndex + 1) of \(questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text("Score: \(score)")
                .font(.caption.bold())
                .foregroundStyle(accentColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }

    private var questionCard: some View {
        Text(currentQuestion.question)
            .font(.title3.bold())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accentColor.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var answerGrid: some View {
        VStack(spacing: 10) {
            ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { idx, option in
                AnswerButton(
                    text: option,
                    state: answerState(for: idx),
                    action: { selectAnswer(idx) }
                )
            }
        }
    }

    @ViewBuilder
    private var explanationCard: some View {
        let isCorrect = selectedAnswer == currentQuestion.correctIndex
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isCorrect ? .green : .red)
                Text(isCorrect ? "Correct!" : "Not quite.")
                    .font(.headline)
                    .foregroundStyle(isCorrect ? .green : .red)
            }
            Text(currentQuestion.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    @ViewBuilder
    private var nextButton: some View {
        if showResult {
            Button {
                advanceQuestion()
            } label: {
                HStack {
                    Text(currentIndex < questions.count - 1 ? "Next Question" : "See Results")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Logic

    private func answerState(for idx: Int) -> AnswerButton.State {
        guard showResult else {
            return selectedAnswer == idx ? .selected : .normal
        }
        if idx == currentQuestion.correctIndex { return .correct }
        if idx == selectedAnswer { return .wrong }
        return .normal
    }

    private func selectAnswer(_ idx: Int) {
        guard !showResult else { return }
        selectedAnswer = idx
        withAnimation { showResult = true }
        if idx == currentQuestion.correctIndex { score += 1 }
    }

    private func advanceQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            selectedAnswer = nil
            withAnimation { showResult = false }
        } else {
            progressStore.recordQuizScore(topicID: topicID, score: score, total: questions.count)
            quizDone = true
        }
    }

    private func resetQuiz() {
        currentIndex = 0
        selectedAnswer = nil
        showResult = false
        score = 0
        quizDone = false
    }
}

// MARK: - Answer Button

struct AnswerButton: View {
    enum State { case normal, selected, correct, wrong }

    let text: String
    let state: State
    let action: () -> Void

    var backgroundColor: Color {
        switch state {
        case .normal:   return Color(.secondarySystemBackground)
        case .selected: return .blue.opacity(0.12)
        case .correct:  return .green.opacity(0.12)
        case .wrong:    return .red.opacity(0.12)
        }
    }

    var borderColor: Color {
        switch state {
        case .normal:   return Color(.systemGray4)
        case .selected: return .blue
        case .correct:  return .green
        case .wrong:    return .red
        }
    }

    var leadingIcon: String? {
        switch state {
        case .correct: return "checkmark.circle.fill"
        case .wrong:   return "xmark.circle.fill"
        default:       return nil
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = leadingIcon {
                    Image(systemName: icon)
                        .foregroundStyle(state == .correct ? .green : .red)
                }
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
        .disabled(state == .correct || state == .wrong)
    }
}

// MARK: - Result View

private struct QuizResultView: View {
    let score: Int
    let total: Int
    let accentColor: Color
    let onRetry: () -> Void

    private var percentage: Double { Double(score) / Double(total) }
    private var grade: String {
        switch percentage {
        case 1.0:        return "Perfect! 🎉"
        case 0.67...:    return "Good job! 👍"
        default:         return "Keep studying 📚"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(score)/\(total)").font(.title.bold())
                    Text(grade).font(.caption).foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 6) {
                Text(grade).font(.title2.bold())
                Text("You scored \(score) out of \(total) questions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("Try Again") { onRetry() }
                .font(.headline)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(accentColor)
                .foregroundStyle(.white)
                .clipShape(Capsule())

            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        QuizView(
            questions: InterviewTopicsLibrary.memoryManagement.quiz,
            topicID: "memory",
            accentColor: .blue
        )
    }
    .environmentObject(ProgressStore())
}
