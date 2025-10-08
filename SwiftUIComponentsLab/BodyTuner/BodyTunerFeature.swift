import Foundation

@objc public enum SmootherChannel: Int { case body, face }

enum BodyTunerFeature: Int, CaseIterable {
    case  AutoBelly, AutoSmoother,  Enhance, Waist, AutoWaist, AutoArm, AutoShoulder, AutoNeck, AutoChest, AutoCleavage, AutoLeg, AutoWidth, AutoHip 

    func description() -> String {
        switch self {
        case .Enhance: return "Enhance"
        case .Waist: return "Slim"
        case .AutoWaist: return "Waist"
        case .AutoArm: return "Arm"
        case .AutoShoulder: return "Shoulder"
        case .AutoNeck: return "Neck"
        case .AutoChest: return "Chest"
        case .AutoCleavage: return "AI Chest"
        case .AutoLeg: return "Leg"
        case .AutoWidth: return "Width"
        case .AutoHip: return "Hip"
        case .AutoBelly: return "Belly"
        case .AutoSmoother: return "Smoother"
        }
    }

    var isAutoFeature: Bool {
        return self == .AutoWaist || self == .AutoLeg || self == .AutoArm || self == .AutoWidth || self == .AutoShoulder || self == .AutoNeck || self == .AutoChest || self == .AutoBelly || self == .AutoHip || self == .AutoSmoother
    }

    var canProtectHead: Bool {
        return self == .AutoWidth
    }

    var useDegreeControlBar: Bool {
        return self == .Enhance || self == .Waist || self == .AutoWaist || self == .AutoLeg || self == .AutoArm || self == .AutoWidth || self == .AutoShoulder || self == .AutoNeck || self == .AutoChest || self == .AutoBelly || self == .AutoHip
    }

    var showMiddleDot: Bool {
        return self == .Enhance || self == .Waist || self == .AutoWaist || self == .AutoLeg || self == .AutoArm || self == .AutoWidth || self == .AutoShoulder || self == .AutoChest || self == .AutoBelly || self == .AutoHip 
    }

    var showNegativeValueOnLabel:Bool {
        return self == .AutoNeck
    }

    var supportsOrientation: Bool {
        return self == .AutoArm || self == .AutoLeg || self == .AutoShoulder || self == .AutoNeck || self == .AutoChest
    }
}


