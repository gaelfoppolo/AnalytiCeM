//
//  EEGSnapshot.swift
//  AnalytiCeM
//
//  Created by Gaël on 15/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

public enum EEGType: Int {
    case eeg
    
    case alphaAbsolute
    case betaAbsolute
    case deltaAbsolute
    case thetaAbsolute
    case gammaAbsolute
    
    case alphaRelative
    case betaRelative
    case deltaRelative
    case thetaRelative
    case gammaRelative
    
    case alphaScore
    case betaScore
    case deltaScore
    case thetaScore
    case gammaScore
    
    public init(_ value: IXNMuseDataPacketType.RawValue) {
        self = EEGType(value)
    }
    
    public static func fromMuse(type: IXNMuseDataPacketType) -> EEGType? {
        switch type {
            case .eeg:
                return .eeg
            case .alphaRelative:
                return .alphaRelative
            case .betaRelative:
                return .betaRelative
            case .deltaRelative:
                return .deltaRelative
            case .thetaRelative:
                return .thetaRelative
            case .gammaRelative:
                return .gammaRelative
            default:
                return nil
            }
    }
    
}

public struct EEGSnapshot {
    
    var leftEar: Double?
    var leftFront: Double?
    var rightFront: Double?
    var rightEar: Double?
    
    public var value: Double {
        
        var sum: Double = 0
        var count: Double = 0
        
        if let leftEar = leftEar {
            sum += leftEar
            count += 1
        }
        
        if let leftFront = leftEar {
            sum += leftFront
            count += 1
        }
        
        if let rightFront = leftEar {
            sum += rightFront
            count += 1
        }
        
        if let rightEar = leftEar {
            sum += rightEar
            count += 1
        }
        
        let returnn: Double
        
        // si aucune valeur
        if (count == 0 || sum == 0) {
            returnn = 0
        // s'il y a des valeurs
        } else  {
            returnn = sum/count
        }
        
        return returnn
        
    }
    
    public static let allZeros = EEGSnapshot()
    
    public init() {
        leftEar = nil
        leftFront = nil
        rightFront = nil
        rightEar = nil
    }
    
    public init?(data: IXNMuseDataPacket) {
        
        // check type
        let acceptedType = [
            IXNMuseDataPacketType.eeg,
            
            IXNMuseDataPacketType.alphaAbsolute,
            IXNMuseDataPacketType.betaAbsolute,
            IXNMuseDataPacketType.deltaAbsolute,
            IXNMuseDataPacketType.thetaAbsolute,
            IXNMuseDataPacketType.gammaAbsolute,
            
            IXNMuseDataPacketType.alphaRelative,
            IXNMuseDataPacketType.betaRelative,
            IXNMuseDataPacketType.deltaRelative,
            IXNMuseDataPacketType.thetaRelative,
            IXNMuseDataPacketType.gammaRelative,
            
            IXNMuseDataPacketType.alphaScore,
            IXNMuseDataPacketType.betaScore,
            IXNMuseDataPacketType.deltaScore,
            IXNMuseDataPacketType.thetaScore,
            IXNMuseDataPacketType.gammaScore
        ]
        
        guard acceptedType.contains(data.packetType()) else { return nil }
    
        func extractPoint(_ key: Int) -> Double? {
            let val = data.values()[key].doubleValue
            return (val.isNaN) ? nil : val
        }
        
        //type = EEGType(data.packetType().rawValue)
        leftEar = extractPoint(IXNEeg.EEG1.rawValue)
        leftFront = extractPoint(IXNEeg.EEG2.rawValue)
        rightFront = extractPoint(IXNEeg.EEG3.rawValue)
        rightEar = extractPoint(IXNEeg.EEG4.rawValue)
        
    }
}
