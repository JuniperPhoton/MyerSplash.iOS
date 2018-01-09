import Foundation

extension String {
    func subString(to: Int) -> String {
        return subString(0, to)
    }

    func subString(from: Int) -> String {
        return subString(from, self.count - 1)
    }

    func subString(_ from: Int, _ to: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: from)...self.index(self.startIndex, offsetBy: to)])
    }
}