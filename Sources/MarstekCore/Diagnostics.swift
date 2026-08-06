import Foundation

public struct MarstekHMEvent: Equatable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let type: Int
    public let code: Int

    public init(year: Int, month: Int, day: Int, hour: Int, minute: Int, type: Int, code: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.type = type
        self.code = code
    }
}

public struct MarstekFaultDescriptor: Equatable {
    public let categoryKey: String
    public let statusKey: String
    public let treatmentKey: String

    public init(categoryKey: String, statusKey: String, treatmentKey: String) {
        self.categoryKey = categoryKey
        self.statusKey = statusKey
        self.treatmentKey = treatmentKey
    }
}

public enum MarstekDiagnostics {
    /// HM Event Log records are 9 bytes: year (LE), month, day, hour, minute,
    /// event type, and code (LE). The payload can contain trailing bytes on
    /// firmware variants, so only complete records are decoded.
    public static func parseHMEvents(_ payload: [UInt8]) -> [MarstekHMEvent] {
        guard payload.count >= 9 else { return [] }
        var events: [MarstekHMEvent] = []

        for offset in stride(from: 0, through: payload.count - 9, by: 9) {
            let year = Int(payload[offset]) | (Int(payload[offset + 1]) << 8)
            let month = Int(payload[offset + 2])
            let day = Int(payload[offset + 3])
            let hour = Int(payload[offset + 4])
            let minute = Int(payload[offset + 5])
            let type = Int(payload[offset + 6])
            let code = Int(payload[offset + 7]) | (Int(payload[offset + 8]) << 8)

            guard (2000...2100).contains(year), (1...12).contains(month),
                  (1...31).contains(day), (0...23).contains(hour),
                  (0...59).contains(minute) else { continue }

            events.append(MarstekHMEvent(year: year, month: month, day: day,
                                         hour: hour, minute: minute, type: type,
                                         code: code))
        }
        return events
    }

    public static func codeText(_ code: Int) -> String {
        String(format: "%d (0x%04X)", code, code)
    }

    public static func sortedHMEventsNewestFirst(_ events: [MarstekHMEvent]) -> [MarstekHMEvent] {
        events.sorted {
            if $0.year != $1.year { return $0.year > $1.year }
            if $0.month != $1.month { return $0.month > $1.month }
            if $0.day != $1.day { return $0.day > $1.day }
            if $0.hour != $1.hour { return $0.hour > $1.hour }
            if $0.minute != $1.minute { return $0.minute > $1.minute }
            return $0.code > $1.code
        }
    }

    public static func fault(for code: Int) -> MarstekFaultDescriptor? {
        let inverter = "faultInverterSide"
        let battery = "faultBatSide"
        let grid = "faultGridSide"

        switch code {
        case 400: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault400Status", treatmentKey: "fault400Treatment")
        case 401: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault401Status", treatmentKey: "fault401Treatment")
        case 402: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault402Status", treatmentKey: "fault402Treatment")
        case 405: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault405Status", treatmentKey: "fault405Treatment")
        case 410...430: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault410Status", treatmentKey: "fault410Treatment")
        case 431: return MarstekFaultDescriptor(categoryKey: battery, statusKey: "fault431Status", treatmentKey: "fault431Treatment")
        case 432: return MarstekFaultDescriptor(categoryKey: battery, statusKey: "fault432Status", treatmentKey: "fault432Treatment")
        case 433: return MarstekFaultDescriptor(categoryKey: battery, statusKey: "fault433Status", treatmentKey: "fault433Treatment")
        case 434: return MarstekFaultDescriptor(categoryKey: battery, statusKey: "fault434Status", treatmentKey: "fault434Treatment")
        case 440, 441: return MarstekFaultDescriptor(categoryKey: grid, statusKey: "fault440Status", treatmentKey: "fault440Treatment")
        case 442: return MarstekFaultDescriptor(categoryKey: grid, statusKey: "fault442Status", treatmentKey: "fault442Treatment")
        case 443: return MarstekFaultDescriptor(categoryKey: grid, statusKey: "fault443Status", treatmentKey: "fault443Treatment")
        case 444: return MarstekFaultDescriptor(categoryKey: grid, statusKey: "fault444Status", treatmentKey: "fault444Treatment")
        case 445: return MarstekFaultDescriptor(categoryKey: grid, statusKey: "fault445Status", treatmentKey: "fault445Treatment")
        case 446: return MarstekFaultDescriptor(categoryKey: grid, statusKey: "fault446Status", treatmentKey: "fault446Treatment")
        case 447: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault447Status", treatmentKey: "fault447Treatment")
        case 448: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault448Status", treatmentKey: "fault448Treatment")
        case 530, 558: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault530Status", treatmentKey: "fault530Treatment")
        case 559: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault559Status", treatmentKey: "fault559Treatment")
        case 560: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault560Status", treatmentKey: "fault560Treatment")
        case 0x5C0: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault5C0Status", treatmentKey: "fault5C0Treatment")
        case 0x5C1: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault5C1Status", treatmentKey: "fault5C1Treatment")
        case 0x5C2...0x5C4: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault5C2Status", treatmentKey: "fault5C2Treatment")
        case 0x5C8...0x5CB: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault5C8Status", treatmentKey: "fault5C8Treatment")
        case 0x5D2: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault5D2Status", treatmentKey: "fault5D2Treatment")
        case 0x5D3: return MarstekFaultDescriptor(categoryKey: inverter, statusKey: "fault5D3Status", treatmentKey: "fault5D3Treatment")
        default: return nil
        }
    }
}
