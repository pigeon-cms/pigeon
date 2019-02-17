import Foundation

extension String {

    /// Converts this string to camelCase. Can convert sentence formatted, snake_case, and kebab-case.
    /// Only alphanumerics are allowed.
    func camelCase() -> String {
        let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let whiteSpaceSplit = self.split(omittingEmptySubsequences: true) { char -> Bool in
            switch char {
            case " ", " ", " ", " ", "​", "_", "-", "–", "—", ".", ",":
                return true
            default:
                return false
            }
        }

        return whiteSpaceSplit.reduce("") { phrase, word -> String in
            var word = word.filter { return allowedCharacters.contains($0) }

            if phrase == "" {
                /// first word in the sequence
                word = word.lowercased()
            } else {
                if word != word.uppercased() && word != word.iosStyle() {
                    word = word.capitalized
                }
            }

            return phrase + word
        }

    }

    /// Converts this string to PascalCase. Can convert sentence formatted, snake_case, and kebab-case.
    /// Only alphanumerics are allowed.
    func pascalCase() -> String {
        let camelCase = self.camelCase()
        guard let first = camelCase.first else { return camelCase }
        return String(first).uppercased() + camelCase.dropFirst()
    }

    /// This string with "iOS" style capitalization, with the first character
    /// lowercase and the rest uppercase.
    func iosStyle() -> String {
        guard self.count > 1 else { return self }
        guard let first = self.first else { return self }

        return String(first).lowercased() + self.dropFirst().uppercased()
    }

}
