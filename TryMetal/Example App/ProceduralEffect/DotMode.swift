enum DotMode: Int, CaseIterable {
    case glow       = 0
    case attraction = 1
    case repulsion  = 2

    var label: String {
        switch self {
        case .glow:       "Glow"
        case .repulsion:  "Repulsion"
        case .attraction: "Attraction"
        }
    }

    var next: DotMode {
        let all = DotMode.allCases
        let idx = (rawValue + 1) % all.count
        return all[idx]
    }
}
