import Foundation
import CoreGraphics

/// Tiny xorshift64 RNG. Deterministic per seed, sufficient for layout jitter.
struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) {
        self.state = seed == 0 ? 0xdeadbeef : seed
    }
    mutating func next() -> UInt64 {
        var x = state
        x ^= x << 13
        x ^= x >> 7
        x ^= x << 17
        state = x
        return x
    }
    mutating func next(upperBound: UInt64) -> UInt64 {
        guard upperBound > 0 else { return 0 }
        return next() % upperBound
    }
    mutating func unitDouble() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }
}

extension ClosedRange where Bound == CGFloat {
    func random(using rng: inout SeededRNG) -> CGFloat {
        let lo = Double(lowerBound)
        let hi = Double(upperBound)
        return CGFloat(lo + (hi - lo) * rng.unitDouble())
    }
}
