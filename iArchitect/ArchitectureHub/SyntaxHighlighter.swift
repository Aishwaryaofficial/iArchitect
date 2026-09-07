import UIKit

// ──────────────────────────────────────────────────────────────────
// Swift Syntax Highlighter
// Lightweight NSAttributedString-based highlighter using regex.
// Supports keywords, types, strings, comments, numbers, @attributes.
// ──────────────────────────────────────────────────────────────────
enum SyntaxHighlighter {

    static func highlight(_ code: String,
                          fontSize: CGFloat = 12,
                          backgroundColor: UIColor = .systemBackground) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: code)
        let fullRange = NSRange(location: 0, length: attributed.length)

        // Base style
        let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        attributed.addAttribute(.font, value: font, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)

        // Apply rules (order matters — later rules override earlier ones)
        apply(pattern: commentLine,   color: .systemGray,    to: attributed)
        apply(pattern: commentBlock,  color: .systemGray,    to: attributed)
        apply(pattern: stringLiteral, color: .systemRed,     to: attributed)
        apply(pattern: keywords,      color: .systemPurple,  to: attributed)
        apply(pattern: typeName,      color: .systemBlue,    to: attributed)
        apply(pattern: attribute,     color: .systemOrange,  to: attributed)
        apply(pattern: number,        color: .systemTeal,    to: attributed)

        return attributed
    }

    // MARK: - Patterns

    private static let commentLine = regex(#"\/\/[^\n]*"#)
    private static let commentBlock = regex(#"\/\*[\s\S]*?\*\/"#)
    private static let stringLiteral = regex(#""[^"\\]*(?:\\.[^"\\]*)*""#)
    private static let attribute  = regex(#"@\w+"#)
    private static let number     = regex(#"\b\d+\.?\d*\b"#)
    private static let typeName   = regex(#"\b[A-Z][A-Za-z0-9]+\b"#)

    private static let keywordList = [
        "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
        "return", "if", "else", "guard", "for", "while", "switch", "case", "default",
        "break", "continue", "import", "override", "static", "final", "private",
        "public", "internal", "fileprivate", "open", "weak", "unowned", "lazy",
        "mutating", "throws", "throw", "try", "catch", "async", "await", "actor",
        "in", "where", "init", "deinit", "nil", "true", "false", "self", "super",
        "typealias", "associatedtype", "some", "any", "inout", "as", "is",
        "convenience", "required", "optional", "dynamic", "indirect"
    ]
    private static let keywords = regex("\\b(" + keywordList.joined(separator: "|") + ")\\b")

    // MARK: - Helpers

    private static func regex(_ pattern: String) -> NSRegularExpression {
        (try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])) ??
        NSRegularExpression()
    }

    private static func apply(pattern: NSRegularExpression,
                               color: UIColor,
                               to string: NSMutableAttributedString) {
        let range = NSRange(location: 0, length: string.length)
        for match in pattern.matches(in: string.string, range: range) {
            string.addAttribute(.foregroundColor, value: color, range: match.range)
        }
    }
}
