import Foundation

enum BodyTunerFeature: Int, CaseIterable {
    case Enhance, Waist, AutoWaist, AutoArm, AutoShoulder, AutoNeck, AutoChest, AutoCleavage, AutoLeg, AutoWidth, AutoHip

    func description() -> String {
        switch self {
        case .Enhance: return "Enhance"
        case .Waist: return "Waist"
        case .AutoWaist: return "Auto Waist"
        case .AutoArm: return "Auto Arm"
        case .AutoShoulder: return "Auto Shoulder"
        case .AutoNeck: return "Auto Neck"
        case .AutoChest: return "Auto Chest"
        case .AutoCleavage: return "AI Chest"
        case .AutoLeg: return "Auto Leg"
        case .AutoWidth: return "Auto Width"
        case .AutoHip: return "Auto Hip"
        }
    }
}


