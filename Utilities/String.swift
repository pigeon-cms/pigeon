import Foundation

extension String {

    /// Converts this string to camelCase. Can convert sentence formatted, snake_case, and pascal-case.
    /// Only alphanumerics are allowed.
    func camelCase() -> String {
        let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let whiteSpaceSplit = self.split(omittingEmptySubsequences: true) { char -> Bool in
            switch char {
            case " ", "_", "-", "–", "—", ".", ",":
                return true
            default:
                return false
            }
        }

        return whiteSpaceSplit.reduce("") { phrase, word -> String in
            var word = word.lowercased()
            word = word.filter { return allowedCharacters.contains($0) }
            if phrase != "" {
                word = word.capitalized
            }
            return phrase + word
        }

    }

}
