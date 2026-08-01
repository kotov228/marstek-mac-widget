import AppKit
import CoreBluetooth
import Foundation
import Darwin
import MarstekCore

enum AppLanguage: String {
    case english = "en"
    case ukrainian = "uk"
    case german = "de"
}

func language() -> AppLanguage {
    AppLanguage(rawValue: UserDefaults.standard.string(forKey: "marstekLanguage") ?? "en") ?? .english
}

private func legacyL(_ key: String) -> String {
    let values: [AppLanguage: [String: String]] = [
        .english: [
            "charging": "Charging", "discharging": "Discharging", "idle": "Idle", "offline": "Offline",
            "lastHour": "Last hour", "last6": "Last 6 hours", "last24": "Last 24 hours", "last7": "Last 7 days", "noData": "No data for this period",
            "waiting": "Waiting for data…", "bmsBle": "BMS via BLE", "settings": "Settings…", "quit": "Quit", "history": "Marstek — charge history",
            "mode": "Current mode", "workMode": "Operating mode", "autoMode": "Self-consumption", "aiMode": "AI optimization", "manualMode": "Manual", "passiveMode": "Passive", "upsMode": "UPS", "manualPower": "Manual power, W (− charge / + discharge)", "upsPower": "UPS charging power: 100–2500 W", "upsHint": "Change this in the Marstek app. It is not available through the Open API.", "aiHint": "AI optimization is enabled by the station.",
            "dod": "Maximum depth of discharge (DOD), %", "dodHint": "88% = use up to 88%; reserve ≈ 12%", "ip": "Marstek IP address", "led": "Case LED",
            "settingsTitle": "Marstek Settings", "settingsInfo": "DOD is the share of battery capacity that may be used.", "apply": "Apply", "cancel": "Cancel", "save": "Save", "language": "Language",
            "english": "English", "ukrainian": "Ukrainian", "german": "German", "temperature": "Temperature", "capacity": "Capacity", "grid": "Grid", "load": "Load", "autoSearch": "Find automatically", "searching": "Searching…", "found": "Found", "chooseStation": "Choose station",
            "scanTitle": "Marstek BLE diagnostics", "scanInfo": "Scanning nearby and reading BMS data. This can take up to 10 seconds.", "bmsTitle": "Marstek BMS",
            "bmsVersion": "BMS version", "voltage": "Voltage", "current": "Current", "bmsCapacity": "Capacity", "bmsTemperature": "BMS temperature", "mosfet": "MOSFET",
            "noErrors": "No errors", "error": "Error", "warning": "Warning", "cells": "Cells", "bluetoothOn": "Turn on Bluetooth on your Mac.",
            "bluetoothPermission": "Allow Marstek Widget to access Bluetooth in System Settings → Privacy & Security → Bluetooth.", "bleUnsupported": "This Mac does not support Bluetooth Low Energy.",
            "notFound": "Marstek was not found. Move closer to the station.", "bleBusy": "A BLE scan is already running.", "bleChars": "Marstek BLE characteristics were not found.",
            "bmsIncomplete": "The BMS response is incomplete.", "runtimeIncomplete": "The runtime response is incomplete.", "bleTimeout": "The BLE command did not respond.",
            "openApiInfo": "Open API must be enabled in the Marstek app.", "dodRange": "DOD must be between 30 and 88%.", "manualPowerRange": "Manual power must be between −5000 and 5000 W.", "settingsPartial": "Not all settings were applied", "settingsPartialInfo": "UPS did not switch. Check /tmp/marstek-widget.log for details.", "modeNotConfirmed": "Mode was not confirmed by the station", "modeNotConfirmedInfo": "The station did not switch to %@. DOD and LED were not changed. Check /tmp/marstek-widget.log."
        ],
        .ukrainian: [
            "charging": "Заряджається", "discharging": "Розряджається", "idle": "Очікує", "offline": "Немає зв’язку",
            "lastHour": "Остання година", "last6": "Останні 6 годин", "last24": "Останні 24 години", "last7": "Останні 7 днів", "noData": "Ще немає даних за цей період",
            "waiting": "Очікування даних…", "bmsBle": "BMS по BLE", "settings": "Налаштування…", "quit": "Вийти", "history": "Marstek — історія заряду",
            "mode": "Поточний режим", "workMode": "Режим роботи", "autoMode": "Власне споживання", "aiMode": "AI оптимізація", "manualMode": "Ручний", "passiveMode": "Пасивний", "upsMode": "UPS", "manualPower": "Потужність Manual, Вт (− заряд / + розряд)", "upsPower": "Потужність заряджання UPS: 100–2500 Вт", "upsHint": "Змінюється у застосунку Marstek. Через Open API недоступна.", "aiHint": "AI optimization увімкнено станцією.",
            "dod": "Максимальна глибина розряду (DOD), %", "dodHint": "88% = розрядити максимум 88%; резерв ≈ 12%", "ip": "IP-адреса Marstek", "led": "LED на корпусі",
            "settingsTitle": "Налаштування Marstek", "settingsInfo": "DOD — частка ємності батареї, яку дозволено використати.", "apply": "Застосувати", "cancel": "Скасувати", "save": "Зберегти", "language": "Мова",
            "english": "Англійська", "ukrainian": "Українська", "german": "Німецька", "temperature": "Температура", "capacity": "Ємність", "grid": "Мережа", "load": "Навантаження", "autoSearch": "Знайти автоматично", "searching": "Пошук…", "found": "Знайдено", "chooseStation": "Обери станцію",
            "scanTitle": "BLE-діагностика Marstek", "scanInfo": "Сканую станцію поблизу та читаю BMS. Це займає до 10 секунд.", "bmsTitle": "BMS Marstek",
            "bmsVersion": "Версія BMS", "voltage": "Напруга", "current": "Струм", "bmsCapacity": "Ємність", "bmsTemperature": "Температура BMS", "mosfet": "MOSFET",
            "noErrors": "Помилок немає", "error": "Помилка", "warning": "Warning", "cells": "Комірки", "bluetoothOn": "Увімкни Bluetooth на Mac.",
            "bluetoothPermission": "Надай Marstek Widget доступ до Bluetooth у System Settings → Privacy & Security → Bluetooth.", "bleUnsupported": "Цей Mac не підтримує Bluetooth Low Energy.",
            "notFound": "Marstek не знайдено. Підійди ближче до станції.", "bleBusy": "BLE-сканування вже виконується.", "bleChars": "BLE-характеристики Marstek не знайдені.",
            "bmsIncomplete": "BMS-відповідь неповна.", "runtimeIncomplete": "Runtime-відповідь неповна.", "bleTimeout": "BLE-команда не відповіла.",
            "openApiInfo": "Open API має бути увімкнений у застосунку Marstek.", "dodRange": "DOD має бути від 30 до 88%.", "manualPowerRange": "Потужність Manual має бути від −5000 до 5000 Вт.", "settingsPartial": "Не всі налаштування застосовано", "settingsPartialInfo": "UPS не перемкнувся. Перевір /tmp/marstek-widget.log для деталей.", "modeNotConfirmed": "Режим не підтверджено станцією", "modeNotConfirmedInfo": "Станція не перейшла в %@. DOD і LED не змінювалися. Перевір /tmp/marstek-widget.log."
        ],
        .german: [
            "charging": "Wird geladen", "discharging": "Entladung", "idle": "Wartet", "offline": "Keine Verbindung",
            "lastHour": "Letzte Stunde", "last6": "Letzte 6 Stunden", "last24": "Letzte 24 Stunden", "last7": "Letzte 7 Tage", "noData": "Keine Daten für diesen Zeitraum",
            "waiting": "Warte auf Daten…", "bmsBle": "BMS über BLE", "settings": "Einstellungen…", "quit": "Beenden", "history": "Marstek — Ladeverlauf",
            "mode": "Aktueller Modus", "workMode": "Betriebsmodus", "autoMode": "Eigenverbrauch", "aiMode": "AI-Optimierung", "manualMode": "Manuell", "passiveMode": "Passiv", "upsMode": "UPS", "manualPower": "Manual-Leistung, W (− Laden / + Entladen)", "upsPower": "UPS-Ladeleistung: 100–2500 W", "upsHint": "In der Marstek-App ändern. Über die Open API nicht verfügbar.", "aiHint": "AI-Optimierung ist aktiviert.",
            "dod": "Maximale Entladetiefe (DOD), %", "dodHint": "88% = bis zu 88% nutzen; Reserve ≈ 12%", "ip": "Marstek-IP-Adresse", "led": "LED am Gerät",
            "settingsTitle": "Marstek-Einstellungen", "settingsInfo": "DOD ist der Anteil der Akkukapazität, der genutzt werden darf.", "apply": "Anwenden", "cancel": "Abbrechen", "save": "Speichern", "language": "Sprache",
            "english": "Englisch", "ukrainian": "Ukrainisch", "german": "Deutsch", "temperature": "Temperatur", "capacity": "Kapazität", "grid": "Netz", "load": "Last", "autoSearch": "Automatisch suchen", "searching": "Suche…", "found": "Gefunden", "chooseStation": "Station auswählen",
            "scanTitle": "Marstek-BLE-Diagnose", "scanInfo": "Suche nach der Station und lese BMS-Daten. Dies kann bis zu 10 Sekunden dauern.", "bmsTitle": "Marstek BMS",
            "bmsVersion": "BMS-Version", "voltage": "Spannung", "current": "Strom", "bmsCapacity": "Kapazität", "bmsTemperature": "BMS-Temperatur", "mosfet": "MOSFET",
            "noErrors": "Keine Fehler", "error": "Fehler", "warning": "Warnung", "cells": "Zellen", "bluetoothOn": "Schalte Bluetooth auf dem Mac ein.",
            "bluetoothPermission": "Erlaube Marstek Widget den Bluetooth-Zugriff unter Systemeinstellungen → Datenschutz & Sicherheit → Bluetooth.", "bleUnsupported": "Dieser Mac unterstützt Bluetooth Low Energy nicht.",
            "notFound": "Marstek wurde nicht gefunden. Gehe näher an die Station.", "bleBusy": "Ein BLE-Scan läuft bereits.", "bleChars": "Marstek-BLE-Eigenschaften wurden nicht gefunden.",
            "bmsIncomplete": "Die BMS-Antwort ist unvollständig.", "runtimeIncomplete": "Die Laufzeitantwort ist unvollständig.", "bleTimeout": "Der BLE-Befehl hat nicht geantwortet.",
            "openApiInfo": "Die Open API muss in der Marstek-App aktiviert sein.", "dodRange": "DOD muss zwischen 30 und 88% liegen.", "manualPowerRange": "Die Manual-Leistung muss zwischen −5000 und 5000 W liegen.", "settingsPartial": "Nicht alle Einstellungen wurden angewendet", "settingsPartialInfo": "UPS wurde nicht umgeschaltet. Siehe /tmp/marstek-widget.log für Details.", "modeNotConfirmed": "Der Modus wurde von der Station nicht bestätigt", "modeNotConfirmedInfo": "Die Station wechselte nicht zu %@. DOD und LED wurden nicht geändert. Siehe /tmp/marstek-widget.log."
        ]
    ]
    return values[language()]?[key] ?? values[.english]?[key] ?? key
}

private func localizedState(_ state: String) -> String {
    switch state {
    case BatteryReading.State.charging.rawValue: return L("charging")
    case BatteryReading.State.discharging.rawValue: return L("discharging")
    case BatteryReading.State.idle.rawValue: return L("idle")
    default: return state
    }
}

private func localizedMode(_ mode: String) -> String {
    switch mode.lowercased() {
    case "auto": return L("autoMode")
    case "ai": return L("aiMode")
    case "manual": return L("manualMode")
    case "passive": return L("passiveMode")
    case "ups": return L("upsMode")
    default: return mode
    }
}

struct BLEDiagnostics {
    let deviceName: String
    let bmsVersion: Int?
    let batteryVoltage: Double?
    let batteryCurrent: Double?
    let stateOfHealth: Int?
    let designCapacityWh: Int?
    let bmsTemperature: Int?
    let mosfetTemperature: Int?
    let cellVoltages: [Double]
    let errorCode: Int?
    let warningCode: UInt32?
    let runtimeMs: UInt32?
    let gridPower: Int?
    let batteryPower: Int?
    let deviceFirmware: Int?
}

final class MarstekBLEClient: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let serviceUUID = CBUUID(string: "0000FF00-0000-1000-8000-00805F9B34FB")
    private let txUUID = CBUUID(string: "0000FF01-0000-1000-8000-00805F9B34FB")
    private let rxUUID = CBUUID(string: "0000FF02-0000-1000-8000-00805F9B34FB")
    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var tx: CBCharacteristic?
    private var rx: CBCharacteristic?
    private var responseBuffer = Data()
    private var pending: [(UInt8, ([UInt8]) -> Void)] = []
    private var completion: ((Result<BLEDiagnostics, Error>) -> Void)?
    private var timeoutWork: DispatchWorkItem?
    private var scanStarted = false

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }

    func readDiagnostics(completion: @escaping (Result<BLEDiagnostics, Error>) -> Void) {
        guard self.completion == nil else { completion(.failure(NSError(domain: "Marstek BLE", code: 2, userInfo: [NSLocalizedDescriptionKey: L("bleBusy")] ))); return }
        self.completion = completion
        startScanIfReady()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard completion != nil else { return }
        if central.state == .poweredOn {
            startScanIfReady()
        } else if central.state == .poweredOff {
            finish(.failure(NSError(domain: "Marstek BLE", code: 1, userInfo: [NSLocalizedDescriptionKey: L("bluetoothOn")])))
        } else if central.state == .unauthorized {
            finish(.failure(NSError(domain: "Marstek BLE", code: 11, userInfo: [NSLocalizedDescriptionKey: L("bluetoothPermission")])))
        } else if central.state == .unsupported {
            finish(.failure(NSError(domain: "Marstek BLE", code: 12, userInfo: [NSLocalizedDescriptionKey: L("bleUnsupported")])))
        }
    }

    private func startScanIfReady() {
        guard !scanStarted, completion != nil, central.state == .poweredOn else { return }
        scanStarted = true
        // Some Venus firmware does not advertise FF00 even though the service
        // becomes available after connection, so scan by name and inspect the
        // service after connecting.
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            guard let self, self.peripheral == nil, self.completion != nil else { return }
            self.central.stopScan()
            self.finish(.failure(NSError(domain: "Marstek BLE", code: 3, userInfo: [NSLocalizedDescriptionKey: L("notFound")])))
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard self.peripheral == nil else { return }
        let name = peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? ""
        guard name.uppercased().hasPrefix("MST") else { return }
        self.peripheral = peripheral
        central.stopScan()
        scanStarted = false
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        finish(.failure(error ?? NSError(domain: "Marstek BLE", code: 4)))
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if completion != nil { finish(.failure(error ?? NSError(domain: "Marstek BLE", code: 5))) }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil, let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            finish(.failure(error ?? NSError(domain: "Marstek BLE", code: 6))); return
        }
        peripheral.discoverCharacteristics([txUUID, rxUUID], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else { finish(.failure(error!)); return }
        tx = service.characteristics?.first(where: { $0.uuid == txUUID })
        rx = service.characteristics?.first(where: { $0.uuid == rxUUID })
        guard tx != nil, let rx else {
            finish(.failure(NSError(domain: "Marstek BLE", code: 7, userInfo: [NSLocalizedDescriptionKey: L("bleChars")] ))); return
        }
        peripheral.setNotifyValue(true, for: rx)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, characteristic.uuid == rxUUID else { if let error { finish(.failure(error)) }; return }
        pending = [(0x14, { [weak self] payload in self?.handleBMS(payload) }), (0x03, { [weak self] payload in self?.handleRuntime(payload) })]
        sendNext()
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let value = characteristic.value else { if let error { finish(.failure(error)) }; return }
        responseBuffer.append(value)
        while responseBuffer.count >= 5 {
            let bytes = [UInt8](responseBuffer)
            guard bytes[0] == 0x73 else { responseBuffer.removeFirst(); continue }
            let length = Int(bytes[1])
            guard length >= 5 else { responseBuffer.removeFirst(); continue }
            guard responseBuffer.count >= length else { return }
            let frame = Array(responseBuffer.prefix(length)); responseBuffer.removeFirst(length)
            guard frame[2] == 0x23, frame.last == frame.dropLast().reduce(0, ^) else { continue }
            let command = frame[3]
            let payload = Array(frame[4..<(frame.count - 1)])
            if let index = pending.firstIndex(where: { $0.0 == command }) {
                let handler = pending.remove(at: index).1
                handler(payload)
            }
        }
    }

    private var bms: (Int?, Double?, Double?, Int?, Int?, Int?, Int?, [Double], Int?, UInt32?, UInt32?)?
    private var runtime: (Int?, Int?, Int?)?

    private func handleBMS(_ p: [UInt8]) {
        guard p.count >= 80 else { finish(.failure(NSError(domain: "Marstek BLE", code: 8, userInfo: [NSLocalizedDescriptionKey: L("bmsIncomplete")] ))); return }
        func u16(_ i: Int) -> Int { Int(p[i]) | (Int(p[i + 1]) << 8) }
        func i16(_ i: Int) -> Int { Int(Int16(bitPattern: UInt16(u16(i)))) }
        func u32(_ i: Int) -> UInt32 { UInt32(p[i]) | UInt32(p[i + 1]) << 8 | UInt32(p[i + 2]) << 16 | UInt32(p[i + 3]) << 24 }
        var cells: [Double] = []
        for i in stride(from: 48, to: min(82, p.count - 1), by: 2) { let v = u16(i); if v > 0 && v < 5000 { cells.append(Double(v) / 1000) } }
        let rawSOH = u16(10)
        // Venus firmware variants may leave SOH at zero when it is not
        // available. Never present that sentinel as a real 0% health value.
        let soh = (1...100).contains(rawSOH) ? rawSOH : nil
        // Some BMS revisions report MOSFET temperature in tenths of °C,
        // while older revisions report whole °C.
        let rawMOSFET = u16(38)
        let mosfet = rawMOSFET > 100 ? Int((Double(rawMOSFET) / 10).rounded()) : rawMOSFET
        bms = (u16(0), Double(u16(14)) / 100, Double(i16(16)) / 10, soh, u16(12), u16(18), mosfet, cells, u16(26), u32(28), u32(32))
        sendNext()
    }

    private func handleRuntime(_ p: [UInt8]) {
        guard p.count >= 15 else { finish(.failure(NSError(domain: "Marstek BLE", code: 9, userInfo: [NSLocalizedDescriptionKey: L("runtimeIncomplete")] ))); return }
        func i16(_ i: Int) -> Int { Int(Int16(bitPattern: UInt16(p[i]) | UInt16(p[i + 1]) << 8)) }
        runtime = (i16(0), i16(2), Int(p[12]) | Int(p[13]) << 8)
        let data = bms
        let result = BLEDiagnostics(deviceName: peripheral?.name ?? "Marstek", bmsVersion: data?.0, batteryVoltage: data?.1, batteryCurrent: data?.2, stateOfHealth: data?.3, designCapacityWh: data?.4, bmsTemperature: data?.5, mosfetTemperature: data?.6, cellVoltages: data?.7 ?? [], errorCode: data?.8, warningCode: data?.9, runtimeMs: data?.10, gridPower: runtime?.0, batteryPower: runtime?.1, deviceFirmware: runtime?.2)
        finish(.success(result))
    }

    private func sendNext() {
        guard let next = pending.first, let tx, let peripheral else { return }
        let command = next.0
        let body = [UInt8](arrayLiteral: 0x73, 0x05, 0x23, command)
        let checksum = body.reduce(0, ^)
        peripheral.writeValue(Data(body + [checksum]), for: tx, type: .withoutResponse)
        timeoutWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.finish(.failure(NSError(domain: "Marstek BLE", code: 10, userInfo: [NSLocalizedDescriptionKey: L("bleTimeout")]))) }
        timeoutWork = work; DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: work)
    }

    private func finish(_ result: Result<BLEDiagnostics, Error>) {
        timeoutWork?.cancel(); timeoutWork = nil
        central.stopScan()
        if let peripheral, let rx { peripheral.setNotifyValue(false, for: rx) }
        if let peripheral { central.cancelPeripheralConnection(peripheral) }
        let callback = completion; completion = nil; self.peripheral = nil; tx = nil; rx = nil; pending.removeAll(); responseBuffer.removeAll(); bms = nil; runtime = nil
        callback?(result)
    }
}

struct BatteryReading {
    let soc: Double
    let state: State
    let watts: Double
    let updatedAt: Date
    let mode: String?
    let temperature: Double?
    let capacityWh: Double?
    let ratedCapacityWh: Double?
    let solarPower: Double?
    let gridPower: Double?
    let offgridPower: Double?
    let totalPVEnergyWh: Double?
    let totalGridInputEnergyWh: Double?
    let totalGridOutputEnergyWh: Double?
    let totalLoadEnergyWh: Double?
    let wifiRSSI: Double?
    let wifiSSID: String?
    let ctConnected: Bool?

    enum State: String {
        case charging = "Заряджається"
        case discharging = "Розряджається"
        case idle = "Очікує"
        case offline = "Немає зв’язку"
    }

    func withMode(_ newMode: String?) -> BatteryReading {
        BatteryReading(soc: soc, state: state, watts: watts, updatedAt: updatedAt,
                       mode: newMode, temperature: temperature, capacityWh: capacityWh,
                       ratedCapacityWh: ratedCapacityWh, solarPower: solarPower,
                       gridPower: gridPower, offgridPower: offgridPower,
                       totalPVEnergyWh: totalPVEnergyWh,
                       totalGridInputEnergyWh: totalGridInputEnergyWh,
                       totalGridOutputEnergyWh: totalGridOutputEnergyWh,
                       totalLoadEnergyWh: totalLoadEnergyWh, wifiRSSI: wifiRSSI,
                       wifiSSID: wifiSSID, ctConnected: ctConnected)
    }
}

struct HistorySample: Codable {
    let date: Date
    let soc: Double
    let state: String
    let watts: Double
    let capacityWh: Double?

    init(date: Date, soc: Double, state: String = BatteryReading.State.idle.rawValue, watts: Double = 0, capacityWh: Double? = nil) {
        self.date = date; self.soc = soc; self.state = state; self.watts = watts; self.capacityWh = capacityWh
    }

    enum CodingKeys: String, CodingKey { case date, soc, state, watts, capacityWh }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decode(Date.self, forKey: .date)
        soc = try values.decode(Double.self, forKey: .soc)
        state = try values.decodeIfPresent(String.self, forKey: .state) ?? BatteryReading.State.idle.rawValue
        watts = try values.decodeIfPresent(Double.self, forKey: .watts) ?? 0
        capacityWh = try values.decodeIfPresent(Double.self, forKey: .capacityWh)
    }
}

final class HistoryStore {
    private let key = "marstekHistory"
    private(set) var samples: [HistorySample]

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([HistorySample].self, from: data) {
            samples = saved
        } else {
            samples = []
        }
        trim()
    }

    func add(_ reading: BatteryReading) {
        samples.append(HistorySample(date: reading.updatedAt, soc: reading.soc, state: reading.state.rawValue, watts: reading.watts, capacityWh: reading.capacityWh))
        trim()
        if let data = try? JSONEncoder().encode(samples) { UserDefaults.standard.set(data, forKey: key) }
    }

    private func trim() {
        let cutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        samples = samples.filter { $0.date >= cutoff }
    }
}

final class HistoryGraphView: NSView {
    var samples: [HistorySample] = [] { didSet { needsDisplay = true } }
    var hours: Double = 24 { didSet { needsDisplay = true } }
    private var selected: HistorySample?

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let bounds = bounds.insetBy(dx: 52, dy: 34)
        NSColor.windowBackgroundColor.setFill(); bounds.fill()
        let cutoff = Date().addingTimeInterval(-hours * 3600)
        let visible = samples.filter { $0.date >= cutoff }

        NSColor.separatorColor.setStroke(); context.setLineWidth(0.5)
        for value in stride(from: 0.0, through: 100.0, by: 25.0) {
            let y = bounds.minY + bounds.height * value / 100
            context.move(to: CGPoint(x: bounds.minX, y: y)); context.addLine(to: CGPoint(x: bounds.maxX, y: y)); context.strokePath()
            NSString(format: "%.0f%%", value).draw(at: CGPoint(x: 10, y: y - 7), withAttributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.secondaryLabelColor])
        }

        let stepHours: Double = hours <= 1 ? 0.25 : (hours <= 6 ? 1 : (hours <= 24 ? 4 : 24))
        let start = cutoff.timeIntervalSinceReferenceDate
        let end = Date().timeIntervalSinceReferenceDate
        let step = stepHours * 3600
        let firstTick = ceil(start / step) * step
        let timeFormatter = DateFormatter(); timeFormatter.dateFormat = hours > 24 ? "dd.MM" : "HH:mm"
        for tick in stride(from: firstTick, through: end, by: step) {
            let fraction = (tick - start) / max(1, end - start)
            let x = bounds.minX + bounds.width * CGFloat(fraction)
            context.move(to: CGPoint(x: x, y: bounds.minY)); context.addLine(to: CGPoint(x: x, y: bounds.maxY)); context.strokePath()
            let label = timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: tick))
            let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 10), .foregroundColor: NSColor.secondaryLabelColor]
            let size = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: max(bounds.minX, min(x - size.width / 2, bounds.maxX - size.width)), y: 10), withAttributes: attributes)
        }

        guard !visible.isEmpty else {
            let text = L("noData")
            let size = text.size(withAttributes: [.font: NSFont.systemFont(ofSize: 14), .foregroundColor: NSColor.secondaryLabelColor])
            text.draw(at: CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2), withAttributes: [.font: NSFont.systemFont(ofSize: 14), .foregroundColor: NSColor.secondaryLabelColor])
            return
        }

        let point: (HistorySample) -> CGPoint = { sample in
            let x = bounds.minX + bounds.width * CGFloat((sample.date.timeIntervalSinceReferenceDate - start) / max(1, end - start))
            let y = bounds.minY + bounds.height * CGFloat(sample.soc / 100)
            return CGPoint(x: x, y: y)
        }
        func color(for state: String) -> NSColor {
            switch state {
            case BatteryReading.State.charging.rawValue: return .systemGreen
            case BatteryReading.State.discharging.rawValue: return .systemRed
            case BatteryReading.State.idle.rawValue: return .systemRed.withAlphaComponent(0.35)
            default: return .systemGray
            }
        }
        context.setLineWidth(2.5)
        for pair in zip(visible, visible.dropFirst()) {
            let path = CGMutablePath(); path.move(to: point(pair.0)); path.addLine(to: point(pair.1))
            color(for: pair.1.state).setStroke(); context.addPath(path); context.strokePath()
        }
        let last = point(visible.last!)
        color(for: visible.last!.state).setFill(); context.fillEllipse(in: CGRect(x: last.x - 4, y: last.y - 4, width: 8, height: 8))

        let legend: [(String, NSColor)] = [
            (L("charging"), .systemGreen),
            (L("discharging"), .systemRed),
            (L("idle"), .systemRed.withAlphaComponent(0.35))
        ]
        var legendX = bounds.minX
        for (title, legendColor) in legend {
            legendColor.setFill(); context.fillEllipse(in: CGRect(x: legendX, y: bounds.maxY + 10, width: 8, height: 8))
            title.draw(at: CGPoint(x: legendX + 12, y: bounds.maxY + 7), withAttributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.secondaryLabelColor])
            legendX += title.size(withAttributes: [.font: NSFont.systemFont(ofSize: 11)]).width + 34
        }

        if let selected, let nearest = visible.min(by: { abs($0.date.timeIntervalSince(selected.date)) < abs($1.date.timeIntervalSince(selected.date)) }) {
            let selectedPoint = point(nearest)
            NSColor.systemOrange.setStroke(); context.setLineWidth(1)
            context.move(to: CGPoint(x: selectedPoint.x, y: bounds.minY)); context.addLine(to: CGPoint(x: selectedPoint.x, y: bounds.maxY)); context.strokePath()
            NSColor.systemOrange.setFill(); context.fillEllipse(in: CGRect(x: selectedPoint.x - 5, y: selectedPoint.y - 5, width: 10, height: 10))
            let formatter = DateFormatter(); formatter.dateFormat = hours > 24 ? "dd.MM HH:mm" : "HH:mm"
            var label = "\(formatter.string(from: nearest.date)) · \(Int(nearest.soc.rounded()))%"
            if let capacityWh = nearest.capacityWh {
                label += String(format: " / %.2f kWh", capacityWh / 1000)
            }
            label += " · \(localizedState(nearest.state))"
            if nearest.state != BatteryReading.State.idle.rawValue, nearest.watts > 0 {
                label += " · \(Int(nearest.watts.rounded())) W"
            }
            let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: NSColor.labelColor]
            let size = label.size(withAttributes: attributes)
            let labelX = min(max(selectedPoint.x - size.width / 2, 8), bounds.maxX - size.width - 8)
            let labelRect = NSRect(x: labelX, y: bounds.maxY - 30, width: size.width + 16, height: 24)
            NSColor.controlBackgroundColor.setFill(); NSBezierPath(roundedRect: labelRect, xRadius: 6, yRadius: 6).fill()
            label.draw(at: CGPoint(x: labelRect.minX + 8, y: labelRect.minY + 5), withAttributes: attributes)
        }
    }

    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let bounds = bounds.insetBy(dx: 52, dy: 34)
        let cutoff = Date().addingTimeInterval(-hours * 3600)
        let visible = samples.filter { $0.date >= cutoff }
        guard !visible.isEmpty else { return }
        let start = cutoff.timeIntervalSinceReferenceDate
        let end = Date().timeIntervalSinceReferenceDate
        let hit = visible.min { left, right in
            let leftX = bounds.minX + bounds.width * CGFloat((left.date.timeIntervalSinceReferenceDate - start) / max(1, end - start))
            let rightX = bounds.minX + bounds.width * CGFloat((right.date.timeIntervalSinceReferenceDate - start) / max(1, end - start))
            return abs(leftX - location.x) < abs(rightX - location.x)
        }
        if let hit { selected = hit; needsDisplay = true }
    }
}

final class GraphPanel: NSView {
    let graph = HistoryGraphView()
    let selector = NSPopUpButton()
    let detailsLabel = NSTextField(wrappingLabelWithString: L("waiting"))
    private let bleButton = NSButton(title: L("bmsBle"), target: nil, action: nil)
    private let settingsButton = NSButton(title: L("settings"), target: nil, action: nil)
    private let quitButton = NSButton(title: L("quit"), target: nil, action: nil)
    var onSettings: (() -> Void)?
    var onBLE: (() -> Void)?
    var onQuit: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        selector.addItems(withTitles: [L("lastHour"), L("last6"), L("last24"), L("last7")])
        selector.selectItem(at: 2); selector.target = self; selector.action = #selector(rangeChanged)
        detailsLabel.textColor = .secondaryLabelColor
        detailsLabel.font = NSFont.systemFont(ofSize: 11)
        detailsLabel.preferredMaxLayoutWidth = 680
        addSubview(selector); addSubview(graph); addSubview(detailsLabel)
        bleButton.target = self; bleButton.action = #selector(bleClicked); bleButton.bezelStyle = .rounded
        settingsButton.target = self; settingsButton.action = #selector(settingsClicked); settingsButton.bezelStyle = .rounded
        quitButton.target = self; quitButton.action = #selector(quitClicked); quitButton.bezelStyle = .rounded
        addSubview(bleButton); addSubview(settingsButton); addSubview(quitButton)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layout() {
        selector.frame = NSRect(x: 20, y: bounds.height - 42, width: 180, height: 28)
        graph.frame = NSRect(x: 0, y: 82, width: bounds.width, height: bounds.height - 128)
        detailsLabel.frame = NSRect(x: 20, y: 8, width: max(300, bounds.width - 40), height: 62)
        bleButton.frame = NSRect(x: bounds.width - 350, y: bounds.height - 42, width: 120, height: 28)
        settingsButton.frame = NSRect(x: bounds.width - 220, y: bounds.height - 42, width: 100, height: 28)
        quitButton.frame = NSRect(x: bounds.width - 105, y: bounds.height - 42, width: 85, height: 28)
    }

    func update(_ samples: [HistorySample]) { graph.samples = samples }

    func updateLocalization() {
        selector.removeAllItems()
        selector.addItems(withTitles: [L("lastHour"), L("last6"), L("last24"), L("last7")])
        selector.selectItem(at: 2)
        bleButton.title = L("bmsBle")
        settingsButton.title = L("settings")
        quitButton.title = L("quit")
        needsLayout = true
        graph.needsDisplay = true
    }

    func update(_ reading: BatteryReading, samples: [HistorySample]) {
        graph.samples = samples
        let mode = localizedMode(reading.mode ?? "UPS")
        let temperature = reading.temperature.map { String(format: "%.1f°C", $0) } ?? "—"
        let capacity = reading.capacityWh.map { String(format: "%.2f kWh", $0 / 1000) } ?? "—"
        let ratedCapacity = reading.ratedCapacityWh.map { String(format: "%.2f kWh", $0 / 1000) } ?? "—"
        let gridLabel = L("grid")
        let loadLabel = L("load")
        let temperatureLabel = L("temperature")
        let capacityLabel = L("capacity")
        var currentPower: [String] = []
        if let grid = reading.gridPower, abs(grid) > 0.5 { currentPower.append("\(gridLabel): \(Int(grid.rounded())) W") }
        if let offgrid = reading.offgridPower, abs(offgrid) > 0.5 { currentPower.append("\(loadLabel): \(Int(offgrid.rounded())) W") }
        let currentPowerText = currentPower.isEmpty ? "" : " · " + currentPower.joined(separator: " · ")
        detailsLabel.stringValue = "\(mode) · \(Int(reading.soc.rounded()))% · \(localizedState(reading.state.rawValue)) · \(Int(reading.watts.rounded())) W\n\(temperatureLabel): \(temperature) · \(capacityLabel): \(capacity) / \(ratedCapacity)\(currentPowerText)"
    }

    @objc private func rangeChanged() { graph.hours = [1.0, 6.0, 24.0, 24.0 * 7.0][selector.indexOfSelectedItem] }
    @objc private func bleClicked() { onBLE?() }
    @objc private func settingsClicked() { onSettings?() }
    @objc private func quitClicked() { onQuit?() }
}

private extension Array {
    subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}

final class MarstekClient {
    private let queue = DispatchQueue(label: "marstek.udp")
    private var requestID = 0
    let host: String
    let port: UInt16 = 30000

    init(host: String) { self.host = host }

    func read(completion: @escaping (Result<BatteryReading, Error>) -> Void) {
        queue.async {
            let fd = socket(AF_INET, SOCK_DGRAM, 0)
            guard fd >= 0 else { DispatchQueue.main.async { completion(.failure(NSError(domain: "Marstek", code: 10))) }; return }
            defer { close(fd) }
            var timeout = timeval(tv_sec: 4, tv_usec: 0)
            setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = self.port.bigEndian
            guard self.host.withCString({ inet_pton(AF_INET, $0, &address.sin_addr) }) == 1 else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "Marstek", code: 11))) }; return
            }

            func request(_ method: String, timeoutMilliseconds: Int = 600) -> [String: Any]? {
                timeout = timeval(tv_sec: timeoutMilliseconds / 1000, tv_usec: Int32((timeoutMilliseconds % 1000) * 1000))
                setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
                self.requestID = (self.requestID % 99999) + 1
                let id = self.requestID
                let payload: [String: Any] = ["id": id, "method": method, "params": ["id": 0]]
                guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return nil }
                let sent = data.withUnsafeBytes { bytes in
                    withUnsafePointer(to: &address) { pointer in
                        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                            sendto(fd, bytes.baseAddress, data.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                        }
                    }
                }
                guard sent == data.count else { return nil }
                var buffer = [UInt8](repeating: 0, count: 4096)
            let received = recv(fd, &buffer, buffer.count, 0)
                guard received > 0 else { return nil }
                // The device returns the matching response on this fresh socket.
                // Do not reject it because of NSNumber/Int bridging differences.
                guard let object = try? JSONSerialization.jsonObject(with: Data(buffer[0..<received])) as? [String: Any],
                      let result = object["result"] as? [String: Any] else { return nil }
                return result
            }

            // Requests are deliberately sequential: Marstek firmware may drop
            // packets when Bat.GetStatus and ES.GetStatus arrive together.
            var battery = request("Bat.GetStatus", timeoutMilliseconds: 2000)
            if battery == nil {
                Self.log("Bat.GetStatus: retrying")
                usleep(250_000)
                battery = request("Bat.GetStatus", timeoutMilliseconds: 1000)
            }
            guard let battery else {
                Self.log("Bat.GetStatus: failed after retry")
                DispatchQueue.main.async { completion(.failure(NSError(domain: "Marstek", code: 1))) }
                return
            }
            // Venus firmware needs a short gap between telemetry datagrams.
            usleep(500_000)
            // SOC must not be blocked by a slow or missing ES.GetStatus packet.
            let baseReading = Self.makeReading(battery: battery, energy: [:], mode: nil, wifi: nil, meter: nil)
            let energy = request("ES.GetStatus") ?? [:]
            usleep(150_000)
            let mode = request("ES.GetMode") ?? [:]
            Self.log("ES.GetMode: result=\(mode)")
            usleep(150_000)
            let wifi = request("Wifi.GetStatus") ?? [:]
            usleep(150_000)
            let meter = request("EM.GetStatus") ?? [:]
            guard let reading = Self.makeReading(battery: battery, energy: energy, mode: mode, wifi: wifi, meter: meter) ?? baseReading else {
                Self.log("telemetry: no SOC")
                DispatchQueue.main.async { completion(.failure(NSError(domain: "Marstek", code: 1))) }
                return
            }
            let modeText = reading.mode ?? "?"
            let temperatureText = reading.temperature.map { String($0) } ?? "?"
            Self.log("telemetry: soc=\(reading.soc) state=\(reading.state.rawValue) mode=\(modeText) temp=\(temperatureText)")
            DispatchQueue.main.async { completion(.success(reading)) }
        }
    }

    func discoverHost(completion: @escaping ([String]) -> Void) {
        queue.async {
            let fd = socket(AF_INET, SOCK_DGRAM, 0)
            guard fd >= 0 else { DispatchQueue.main.async { completion([]) }; return }
            defer { close(fd) }
            var broadcast: Int32 = 1
            setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &broadcast, socklen_t(MemoryLayout<Int32>.size))
            var timeout = timeval(tv_sec: 0, tv_usec: 500_000)
            setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = self.port.bigEndian
            address.sin_addr.s_addr = inet_addr("255.255.255.255")
            self.requestID = (self.requestID % 99999) + 1
            let payload: [String: Any] = ["id": self.requestID, "method": "Marstek.GetDevice", "params": ["ble_mac": "0"]]
            guard let data = try? JSONSerialization.data(withJSONObject: payload) else { DispatchQueue.main.async { completion([]) }; return }
            let sent = data.withUnsafeBytes { bytes in
                withUnsafePointer(to: &address) { pointer in
                    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        sendto(fd, bytes.baseAddress, data.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                    }
                }
            }
            guard sent == data.count else { DispatchQueue.main.async { completion([]) }; return }
            var found: [String] = []
            var buffer = [UInt8](repeating: 0, count: 4096)
            while true {
                let received = recv(fd, &buffer, buffer.count, 0)
                guard received > 0 else { break }
                guard let object = try? JSONSerialization.jsonObject(with: Data(buffer[0..<received])) as? [String: Any],
                      let result = object["result"] as? [String: Any] else { continue }
                let ip = (result["ip"] as? String) ?? (result["sta_ip"] as? String)
                if let ip, !ip.isEmpty, !found.contains(ip) { found.append(ip) }
            }
            DispatchQueue.main.async { completion(found) }
        }
    }

    func setPassivePower(_ power: Int, completion: @escaping (Bool) -> Void) {
        queue.async {
            let fd = socket(AF_INET, SOCK_DGRAM, 0)
            guard fd >= 0 else { DispatchQueue.main.async { completion(false) }; return }
            defer { close(fd) }
            var timeout = timeval(tv_sec: 4, tv_usec: 0)
            setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = self.port.bigEndian
            guard self.host.withCString({ inet_pton(AF_INET, $0, &address.sin_addr) }) == 1 else {
                DispatchQueue.main.async { completion(false) }; return
            }
            self.requestID = (self.requestID % 99999) + 1
            let payload: [String: Any] = [
                "id": self.requestID,
                "method": "ES.SetMode",
                "params": ["id": 0, "config": ["mode": "Passive", "passive_cfg": ["power": power, "cd_time": 3600]]]
            ]
            guard let data = try? JSONSerialization.data(withJSONObject: payload) else { DispatchQueue.main.async { completion(false) }; return }
            let sent = data.withUnsafeBytes { bytes in
                withUnsafePointer(to: &address) { pointer in
                    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        sendto(fd, bytes.baseAddress, data.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                    }
                }
            }
            guard sent == data.count else { DispatchQueue.main.async { completion(false) }; return }
            var buffer = [UInt8](repeating: 0, count: 4096)
            let received = recv(fd, &buffer, buffer.count, 0)
            let response = received > 0 ? (try? JSONSerialization.jsonObject(with: Data(buffer[0..<received])) as? [String: Any]) : nil
            let success = response?["error"] == nil && response?["result"] != nil
            DispatchQueue.main.async { completion(success) }
        }
    }

    static func log(_ message: String) {
        let line = "\(Date()) \(message)\n"
        if let data = line.data(using: .utf8), let handle = FileHandle(forWritingAtPath: "/tmp/marstek-widget.log") {
            handle.seekToEndOfFile(); handle.write(data); try? handle.close()
        } else { try? line.write(toFile: "/tmp/marstek-widget.log", atomically: true, encoding: .utf8) }
    }

    func setMode(_ mode: String, power: Int, completion: @escaping (Bool) -> Void) {
        var config: [String: Any] = ["mode": mode]
        if mode == "Auto" { config["auto_cfg"] = ["enable": 1] }
        else if mode == "AI" { config["ai_cfg"] = ["enable": 1] }
        else if mode == "UPS" { config["ups_cfg"] = ["enable": 1] }
        else if mode == "Passive" { config["passive_cfg"] = ["power": power, "cd_time": 3600] }
        // Venus E expects the active schedule in slot 0 and HH:mm values.
        // Slot 9 is reserved for the disabled placeholder used when clearing
        // schedules; sending the real schedule there can leave the device in UPS.
        else if mode == "Manual" { config["manual_cfg"] = ["time_num": 0, "start_time": "00:00", "end_time": "23:59", "week_set": 127, "power": power, "enable": 1] }

        let actualParams: [String: Any] = ["id": 0, "config": config]
        let manualPlaceholderParams: [String: Any] = [
            "id": 0,
            "config": [
                "mode": "Manual",
                "manual_cfg": [
                    "time_num": 9,
                    "start_time": "00:00",
                    "end_time": "00:00",
                    "week_set": 0,
                    "power": 0,
                    "enable": 0
                ]
            ]
        ]
        let verifyAndRetry: (@escaping (Bool) -> Void) -> Void = { [weak self] done in
            guard let self else { done(false); return }
            self.read { result in
                guard case .success(let reading) = result,
                      let reportedMode = MarstekAppLogic.canonicalMode(reading.mode) else {
                    Self.log("ES.SetMode: verification failed, no readable mode")
                    done(false)
                    return
                }
                if reportedMode.caseInsensitiveCompare(mode) == .orderedSame {
                    Self.log("ES.SetMode: verified mode=\(mode)")
                    done(true)
                } else if mode == "Manual", reportedMode == "UPS" {
                    Self.log("ES.SetMode: Manual acknowledged; ES.GetMode reported UPS (ACK_ONLY)")
                    done(true)
                } else {
                    Self.log("ES.SetMode: verification failed, expected=\(mode)")
                    done(false)
                }
            }
        }

        func sendActual(attempt: Int) {
            let send: (@escaping (Bool) -> Void) -> Void = { done in
                guard mode == "Manual" else {
                    self.sendCommand("ES.SetMode", params: actualParams, completion: done)
                    return
                }
                // Venus E keeps a hidden slot 9. Clear it first, otherwise
                // firmware may acknowledge the active schedule but stay in UPS.
                self.sendCommand("ES.SetMode", params: manualPlaceholderParams) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.sendCommand("ES.SetMode", params: actualParams, completion: done)
                    }
                }
            }
            send { [weak self] ok in
                guard self != nil else { completion(false); return }
                guard ok else {
                    if attempt < 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { sendActual(attempt: attempt + 1) }
                    } else { completion(false) }
                    return
                }
                // The station may acknowledge ES.SetMode before ES.GetMode
                // starts returning the new mode. Give firmware time to settle.
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    verifyAndRetry { verified in
                        if verified || attempt >= 3 {
                            completion(verified)
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                sendActual(attempt: attempt + 1)
                            }
                        }
                    }
                }
            }
        }

        // Wake the Local API first. Manual is sent directly with a complete
        // schedule; Venus firmware may reject intermediate mode commands.
        sendCommand("Marstek.GetDevice", params: ["ble_mac": "0"]) { [weak self] _ in
            guard self != nil else { completion(false); return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                sendActual(attempt: 1)
            }
        }
    }

    func setDOD(_ value: Int, completion: @escaping (Bool) -> Void) {
        let clamped = max(30, min(88, value))
        func attempt(_ number: Int) {
            sendCommand("DOD.SET", params: ["value": clamped]) { ok in
                if ok || number >= 3 {
                    completion(ok)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        attempt(number + 1)
                    }
                }
            }
        }
        attempt(1)
    }

    func setLED(_ enabled: Bool, completion: @escaping (Bool) -> Void) {
        sendCommand("Led.Ctrl", params: ["state": enabled ? 1 : 0], completion: completion)
    }

    func setBluetooth(_ enabled: Bool, completion: @escaping (Bool) -> Void) {
        // Marstek API uses enable=0 for ON and enable=1 for OFF.
        sendCommand("Ble.Adv", params: ["enable": enabled ? 0 : 1], completion: completion)
    }

    private func sendCommand(_ method: String, params: [String: Any], completion: @escaping (Bool) -> Void) {
        queue.async {
            let fd = socket(AF_INET, SOCK_DGRAM, 0)
            guard fd >= 0 else { DispatchQueue.main.async { completion(false) }; return }
            defer { close(fd) }
            var timeout = timeval(tv_sec: 4, tv_usec: 0)
            setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            var address = sockaddr_in(); address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size); address.sin_family = sa_family_t(AF_INET); address.sin_port = self.port.bigEndian
            guard self.host.withCString({ inet_pton(AF_INET, $0, &address.sin_addr) }) == 1 else { DispatchQueue.main.async { completion(false) }; return }
            self.requestID = (self.requestID % 99999) + 1
            let payload: [String: Any] = ["id": self.requestID, "method": method, "params": params]
            guard let data = try? JSONSerialization.data(withJSONObject: payload) else { DispatchQueue.main.async { completion(false) }; return }
            if let json = String(data: data, encoding: .utf8) {
                Self.log("\(method): request=\(json)")
            }
            let sent = data.withUnsafeBytes { bytes in withUnsafePointer(to: &address) { pointer in pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sendto(fd, bytes.baseAddress, data.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } } }
            guard sent == data.count else { DispatchQueue.main.async { completion(false) }; return }
            var buffer = [UInt8](repeating: 0, count: 4096)
            let received = recv(fd, &buffer, buffer.count, 0)
            let response = received > 0 ? (try? JSONSerialization.jsonObject(with: Data(buffer[0..<received])) as? [String: Any]) : nil
            let success = method == "ES.SetMode"
                ? MarstekAppLogic.setResultSucceeded(response: response)
                : response?["error"] == nil && response?["result"] != nil
            Self.log("\(method): \(success ? "ok" : "failed") response=\(String(describing: response))")
            DispatchQueue.main.async { completion(success) }
        }
    }

    private static func number(_ value: Any?) -> Double? {
        if let value = value as? Double { return value }
        if let value = value as? NSNumber { return value.doubleValue }
        return nil
    }

    private static func makeReading(battery: [String: Any], energy: [String: Any], mode: [String: Any]?, wifi: [String: Any]?, meter: [String: Any]?) -> BatteryReading? {
        guard let soc = number(battery["soc"]) ?? number(energy["bat_soc"]) else { return nil }
        let power = number(energy["bat_power"]) ?? 0
        // Marstek convention: negative battery power charges, positive discharges.
        let chargingAllowed = boolValue(battery["charg_flag"])
        let dischargingAllowed = boolValue(battery["dischrg_flag"])
        let charging = chargingAllowed && (power < -5 || (number(energy["ongrid_power"]) ?? 0) > 10)
        let discharging = dischargingAllowed && power > 5
        let state: BatteryReading.State = charging ? .charging : (discharging ? .discharging : .idle)
        return BatteryReading(
            soc: max(0, min(100, soc)),
            state: state,
            watts: abs(power),
            updatedAt: Date(),
            mode: mode?["mode"] as? String,
            temperature: number(battery["bat_temp"]),
            capacityWh: number(battery["bat_capacity"]) ?? number(energy["bat_cap"]),
            ratedCapacityWh: number(battery["rated_capacity"]),
            solarPower: number(energy["pv_power"]),
            gridPower: number(energy["ongrid_power"]),
            offgridPower: number(energy["offgrid_power"]),
            totalPVEnergyWh: number(energy["total_pv_energy"]),
            totalGridInputEnergyWh: number(energy["total_grid_input_energy"]),
            totalGridOutputEnergyWh: number(energy["total_grid_output_energy"]),
            totalLoadEnergyWh: number(energy["total_load_energy"]),
            wifiRSSI: number(wifi?["rssi"]),
            wifiSSID: wifi?["ssid"] as? String,
            ctConnected: number(mode?["ct_state"]).map { $0 == 1 } ?? number(meter?["ct_state"]).map { $0 == 1 }
        )
    }

    private static func boolValue(_ value: Any?) -> Bool {
        if let value = value as? Bool { return value }
        if let value = value as? NSNumber { return value.boolValue }
        return false
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var item: NSStatusItem!
    private var timer: Timer?
    private var client: MarstekClient!
    private var reading: BatteryReading?
    private let history = HistoryStore()
    private var graphController: NSWindowController?
    private var graphPanel: GraphPanel?
    // Do not initialize CoreBluetooth at app launch. This keeps the normal
    // UDP widget free of Bluetooth permission prompts until BLE diagnostics
    // are explicitly opened by the user.
    private lazy var bleClient = MarstekBLEClient()
    private weak var settingsHostField: NSTextField?
    private weak var settingsSearchButton: NSButton?
    private weak var settingsUpdateButton: NSButton?
    private weak var discoveredPopup: NSPopUpButton?
    private weak var settingsStatusLabel: NSTextField?
    private weak var settingsAlert: NSAlert?
    private weak var settingsModePopup: NSPopUpButton?
    private let settingsModeValues = MarstekAppLogic.supportedModes
    private weak var settingsManualLabel: NSTextField?
    private weak var settingsManualField: NSTextField?
    private weak var settingsUPSLabel: NSTextField?
    private weak var settingsUPSHint: NSTextField?
    private weak var settingsAIHint: NSTextField?
    private var lastKnownMode = MarstekAppLogic.canonicalMode(
        UserDefaults.standard.string(forKey: "marstekLastKnownMode")
            ?? UserDefaults.standard.string(forKey: "marstekMode")
    )
    private var acknowledgedMode = MarstekAppLogic.canonicalMode(
        UserDefaults.standard.string(forKey: "marstekMode")
    )
    private var host: String { UserDefaults.standard.string(forKey: "marstekHost") ?? "" }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.target = self
        item.button?.action = #selector(openGraph)
        item.button?.title = "🔋 --%"
        // Always discover first. A previously saved IP is only a fallback
        // when the station is temporarily not answering broadcast discovery.
        client = MarstekClient(host: "")
        discoverHostOnStartup()
        timer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in self?.refresh() }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func discoverHostOnStartup() {
        let savedHost = host
        client.discoverHost { [weak self] hosts in
            guard let self else { return }
            if let selectedHost = MarstekAppLogic.selectedHost(discoveredHosts: hosts, savedHost: savedHost) {
                let discovered = hosts.contains(selectedHost)
                MarstekClient.log("startup discovery: found=\(hosts.joined(separator: ",")) selected=\(selectedHost) source=\(discovered ? "discovery" : "fallback")")
                if discovered { UserDefaults.standard.set(selectedHost, forKey: "marstekHost") }
                self.client = MarstekClient(host: selectedHost)
                self.refresh()
            } else if hosts.count > 1 {
                MarstekClient.log("startup discovery: multiple stations found; waiting for user selection: \(hosts.joined(separator: ","))")
            }
        }
    }

    private func refresh() {
        guard !client.host.isEmpty else { return }
        client.read { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                if let reportedMode = MarstekAppLogic.canonicalMode(value.mode) {
                    self.lastKnownMode = reportedMode
                    UserDefaults.standard.set(reportedMode, forKey: "marstekLastKnownMode")
                }
                let displayMode = MarstekAppLogic.effectiveMode(
                    reportedMode: value.mode,
                    lastKnownMode: self.lastKnownMode,
                    acknowledgedMode: self.acknowledgedMode
                )
                if displayMode != MarstekAppLogic.canonicalMode(value.mode) {
                    MarstekClient.log(
                        "mode display: displayed=\(displayMode ?? "?") raw=\(value.mode ?? "?") acknowledged=\(self.acknowledgedMode ?? "?")"
                    )
                }
                let displayValue = value.withMode(displayMode)
                self.reading = displayValue
                self.history.add(displayValue)
                self.item.button?.title = "🔋 \(Int(displayValue.soc.rounded()))%"
                self.graphPanel?.update(displayValue, samples: self.history.samples)
            case .failure:
                // Keep the last good value visible during a temporary UDP loss.
                if self.reading == nil { self.item.button?.title = "🔋 --%" }
            }
        }
    }

    @objc private func openGraph() {
        if graphController == nil {
            let panel = GraphPanel(frame: NSRect(x: 0, y: 0, width: 720, height: 430))
            panel.onSettings = { [weak self] in self?.openSettings() }
            panel.onBLE = { [weak self] in self?.openBLEDiagnostics() }
            panel.onQuit = { [weak self] in self?.quit() }
            graphPanel = panel
            let window = NSWindow(contentRect: panel.frame, styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
            window.title = L("history")
            window.contentView = panel
            window.minSize = NSSize(width: 560, height: 350)
            window.isReleasedWhenClosed = false
            graphController = NSWindowController(window: window)
        }
        graphPanel?.update(history.samples)
        if let reading { graphPanel?.update(reading, samples: history.samples) }
        graphController?.showWindow(nil)
        graphController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func openBLEDiagnostics() {
        let progress = NSAlert()
        progress.messageText = L("scanTitle")
        progress.informativeText = L("scanInfo")
        progress.addButton(withTitle: L("cancel"))
        if let window = graphController?.window {
            progress.beginSheetModal(for: window) { _ in }
        } else {
            progress.runModal()
            return
        }
        bleClient.readDiagnostics { [weak self] result in
            DispatchQueue.main.async {
                progress.window.sheetParent?.endSheet(progress.window)
                let alert = NSAlert()
                switch result {
                case .success(let data):
                    let cells = data.cellVoltages.enumerated().map { "\($0.offset + 1): " + String(format: "%.3f V", $0.element) }.joined(separator: "\n")
                    let bmsVersion = data.bmsVersion.map { String($0) } ?? "—"
                    let voltage = data.batteryVoltage.map { String(format: "%.2f V", $0) } ?? "—"
                    let current = data.batteryCurrent.map { String(format: "%.1f A", $0) } ?? "—"
                    let capacity = data.designCapacityWh.map { "\($0) Wh" } ?? "—"
                    let bmsTemperature = data.bmsTemperature.map { "\($0)°C" } ?? "—"
                    let mosfetTemperature = data.mosfetTemperature.map { "\($0)°C" } ?? "—"
                    let errorCode = data.errorCode.map { String($0) } ?? "—"
                    let warningCode = data.warningCode.map { String($0) } ?? "—"
                    let errorLabel = L("error")
                    let warningLabel = L("warning")
                    let bmsTitle = L("bmsTitle")
                    let bmsVersionLabel = L("bmsVersion")
                    let voltageLabel = L("voltage")
                    let currentLabel = L("current")
                    let capacityLabel = L("bmsCapacity")
                    let temperatureLabel = L("bmsTemperature")
                    let mosfetLabel = L("mosfet")
                    let cellsLabel = L("cells")
                    let diagnosticsText = (data.errorCode == 0 && data.warningCode == 0) ? L("noErrors") : "\(errorLabel): \(errorCode) · \(warningLabel): \(warningCode)"
                    alert.messageText = "\(bmsTitle) — \(data.deviceName)"
                    alert.informativeText = "\(bmsVersionLabel): \(bmsVersion)\n\(voltageLabel): \(voltage) · \(currentLabel): \(current)\n\(capacityLabel): \(capacity)\n\(temperatureLabel): \(bmsTemperature) · \(mosfetLabel): \(mosfetTemperature)\n\(diagnosticsText)\n\(cellsLabel) (\(data.cellVoltages.count)):\n\(cells)"
                case .failure(let error):
                    alert.messageText = L("scanTitle")
                    alert.informativeText = error.localizedDescription
                }
                alert.runModal()
                _ = self
            }
        }
    }

    @objc private func changeHost() {
        let alert = NSAlert(); alert.messageText = L("ip"); alert.informativeText = L("openApiInfo")
        let field = NSTextField(string: host); field.frame = NSRect(x: 0, y: 0, width: 260, height: 24); alert.accessoryView = field
        alert.addButton(withTitle: L("save")); alert.addButton(withTitle: L("cancel"))
        if alert.runModal() == .alertFirstButtonReturn { UserDefaults.standard.set(field.stringValue, forKey: "marstekHost"); client = MarstekClient(host: field.stringValue); refresh() }
    }

    @objc private func discoverIP() {
        settingsSearchButton?.title = L("searching")
        settingsSearchButton?.isEnabled = false
        client.discoverHost { [weak self] hosts in
            guard let self else { return }
            self.settingsSearchButton?.title = L("autoSearch")
            self.settingsSearchButton?.isEnabled = true
            if !hosts.isEmpty {
                self.discoveredPopup?.removeAllItems()
                self.discoveredPopup?.addItems(withTitles: hosts)
                self.discoveredPopup?.isHidden = hosts.count < 2
                let currentHost = self.settingsHostField?.stringValue ?? self.host
                if let selectedHost = MarstekAppLogic.selectedHost(discoveredHosts: hosts, savedHost: currentHost),
                   hosts.contains(selectedHost) {
                    self.settingsHostField?.stringValue = selectedHost
                    self.discoveredPopup?.selectItem(withTitle: selectedHost)
                } else {
                    self.discoveredPopup?.select(nil)
                }
                self.settingsStatusLabel?.stringValue = "\(L("found")): \(hosts.joined(separator: ", "))"
                self.settingsStatusLabel?.isHidden = false
            } else {
                self.settingsStatusLabel?.stringValue = L("notFound")
                self.settingsStatusLabel?.isHidden = false
            }
        }
    }

    @objc private func selectDiscoveredIP() {
        if let selected = discoveredPopup?.titleOfSelectedItem { settingsHostField?.stringValue = selected }
    }

    @objc private func modeChanged() {
        guard let selectedIndex = settingsModePopup?.indexOfSelectedItem,
              let selected = settingsModeValues[safe: selectedIndex] else {
            settingsManualLabel?.isHidden = true
            settingsManualField?.isHidden = true
            settingsUPSLabel?.isHidden = true
            settingsUPSHint?.isHidden = true
            settingsAIHint?.isHidden = true
            return
        }
        let manual = selected == "Manual"
        let ups = selected == "UPS"
        let ai = selected == "AI"
        settingsManualLabel?.isHidden = !manual
        settingsManualField?.isHidden = !manual
        settingsUPSLabel?.isHidden = !ups
        settingsUPSHint?.isHidden = !ups
        settingsAIHint?.isHidden = !ai
    }

    private func openSettings() {
        let currentMode = MarstekAppLogic.effectiveMode(
            reportedMode: reading?.mode,
            lastKnownMode: lastKnownMode
        )
        let modeLabel = NSTextField(labelWithString: L("workMode"))
        let modePopup = NSPopUpButton()
        modePopup.addItems(withTitles: settingsModeValues.map { localizedMode($0) })
        if let currentMode, let currentIndex = settingsModeValues.firstIndex(of: currentMode) {
            modePopup.selectItem(at: currentIndex)
        } else {
            modePopup.select(nil)
        }
        modePopup.target = self
        modePopup.action = #selector(modeChanged)
        settingsModePopup = modePopup
        let isManual = currentMode == "Manual"
        let isUPS = currentMode == "UPS"
        let isAI = currentMode == "AI"
        let manualPowerLabel = NSTextField(labelWithString: L("manualPower"))
        let storedManualPower = UserDefaults.standard.integer(forKey: "marstekManualPower")
        let manualPowerField = NSTextField(string: String(storedManualPower == 0 ? 1000 : storedManualPower))
        manualPowerLabel.isHidden = !isManual
        manualPowerField.isHidden = !isManual
        settingsManualLabel = manualPowerLabel
        settingsManualField = manualPowerField
        let upsPowerLabel = NSTextField(labelWithString: L("upsPower"))
        let upsPowerHint = NSTextField(wrappingLabelWithString: L("upsHint"))
        upsPowerLabel.isHidden = !isUPS
        upsPowerHint.isHidden = !isUPS
        settingsUPSLabel = upsPowerLabel
        settingsUPSHint = upsPowerHint
        let aiHint = NSTextField(labelWithString: L("aiHint"))
        aiHint.textColor = .systemPurple
        aiHint.isHidden = !isAI
        settingsAIHint = aiHint
        upsPowerHint.textColor = .secondaryLabelColor
        upsPowerHint.preferredMaxLayoutWidth = 330
        let hostLabel = NSTextField(labelWithString: L("ip"))
        let hostField = NSTextField(string: host)
        let searchButton = NSButton(title: L("autoSearch"), target: self, action: #selector(discoverIP))
        searchButton.bezelStyle = .rounded
        let updateButton = NSButton(title: L("checkUpdates"), target: self, action: #selector(checkForUpdates))
        updateButton.bezelStyle = .rounded
        let statusLabel = NSTextField(labelWithString: "")
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.preferredMaxLayoutWidth = 330
        statusLabel.isHidden = true
        let discovered = NSPopUpButton()
        discovered.target = self
        discovered.action = #selector(selectDiscoveredIP)
        discovered.isHidden = true
        settingsHostField = hostField
        settingsSearchButton = searchButton
        settingsUpdateButton = updateButton
        discoveredPopup = discovered
        settingsStatusLabel = statusLabel
        let languageLabel = NSTextField(labelWithString: L("language"))
        let languagePopup = NSPopUpButton()
        languagePopup.addItems(withTitles: [L("english"), L("ukrainian"), L("german")])
        languagePopup.selectItem(at: [AppLanguage.english, .ukrainian, .german].firstIndex(of: language()) ?? 0)
        let stack = NSStackView(views: [languageLabel, languagePopup, modeLabel, modePopup, manualPowerLabel, manualPowerField, upsPowerLabel, upsPowerHint, aiHint, hostLabel, hostField, searchButton, discovered, statusLabel, updateButton])
        stack.orientation = .vertical; stack.spacing = 8; stack.alignment = .leading
        stack.frame = NSRect(x: 0, y: 0, width: 340, height: 360)

        let alert = NSAlert()
        alert.messageText = L("settingsTitle")
        alert.informativeText = ""
        alert.accessoryView = stack
        settingsAlert = alert
        alert.addButton(withTitle: L("apply"))
        alert.addButton(withTitle: L("cancel"))
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let selectedMode = settingsModeValues[safe: modePopup.indexOfSelectedItem]
        let targetManual = selectedMode == "Manual"
        guard !targetManual || (Int(manualPowerField.stringValue).map { (-2500...2500).contains($0) } ?? false) else {
            let error = NSAlert(); error.messageText = L("manualPowerRange"); error.runModal(); return
        }
        let newHost = hostField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newHost.isEmpty else { return }
        let manualPower = Int(manualPowerField.stringValue) ?? 1000
        let oldManualPower = UserDefaults.standard.integer(forKey: "marstekManualPower") == 0 ? 1000 : UserDefaults.standard.integer(forKey: "marstekManualPower")
        let modeChanged = selectedMode.map { $0 != currentMode } ?? false
        let manualPowerChanged = targetManual && manualPower != oldManualPower
        UserDefaults.standard.set(newHost, forKey: "marstekHost")
        let selectedLanguage: AppLanguage = [.english, .ukrainian, .german][languagePopup.indexOfSelectedItem]
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "marstekLanguage")
        UserDefaults.standard.set(manualPower, forKey: "marstekManualPower")
        graphPanel?.updateLocalization()
        if let reading { graphPanel?.update(reading, samples: history.samples) }
        graphController?.window?.title = L("history")
        client = MarstekClient(host: newHost)
        guard modeChanged || manualPowerChanged else { refresh(); return }
        if let selectedMode, modeChanged || manualPowerChanged {
            client.setMode(selectedMode, power: manualPower) { modeOK in
                guard modeOK else {
                    let error = NSAlert()
                    error.messageText = L("modeNotConfirmed")
                    error.informativeText = String(format: L("modeNotConfirmedInfo"), localizedMode(selectedMode))
                    error.runModal()
                    self.refresh()
                    return
                }
                self.acknowledgedMode = selectedMode
                UserDefaults.standard.set(selectedMode, forKey: "marstekMode")
                self.refresh()
            }
        }
    }

    @objc private func checkForUpdates() {
        settingsUpdateButton?.isEnabled = false
        settingsUpdateButton?.title = L("checkingUpdates")
        let endpoint = URL(string: "https://api.github.com/repos/kotov228/marstek-mac-widget/releases/latest")!
        var request = URLRequest(url: endpoint)
        request.setValue("Marstek-Mac-Widget", forHTTPHeaderField: "User-Agent")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            guard let data, error == nil,
                  let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                self.finishUpdate(title: L("updateFailed"), message: error?.localizedDescription ?? L("updateFailed"))
                return
            }
            do {
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                guard let asset = release.assets.first(where: { $0.name.hasSuffix(".zip") }) else {
                    self.finishUpdate(title: L("updateFailed"), message: L("releaseAssetMissing"))
                    return
                }
                if !isVersion(release.tagName, newerThan: appVersion()) {
                    self.finishUpdate(title: L("noUpdate"), message: String(format: L("noUpdateInfo"), appVersion()))
                    return
                }
                self.downloadUpdate(asset: asset, releaseTag: release.tagName)
            } catch {
                self.finishUpdate(title: L("updateFailed"), message: error.localizedDescription)
            }
        }.resume()
    }

    private func downloadUpdate(asset: GitHubReleaseAsset, releaseTag: String) {
        URLSession.shared.downloadTask(with: asset.downloadURL) { [weak self] temporaryURL, response, error in
            guard let self else { return }
            guard let temporaryURL, error == nil,
                  let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                self.finishUpdate(title: L("updateFailed"), message: error?.localizedDescription ?? L("updateFailed"))
                return
            }
            do {
                let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                let destination = downloads.appendingPathComponent(asset.name)
                try? FileManager.default.removeItem(at: destination)
                try FileManager.default.copyItem(at: temporaryURL, to: destination)
                DispatchQueue.main.async {
                    self.settingsUpdateButton?.isEnabled = true
                    self.settingsUpdateButton?.title = L("checkUpdates")
                    let alert = NSAlert()
                    alert.messageText = L("updateDownloaded")
                    alert.informativeText = String(format: L("updateDownloadedInfo"), releaseTag, destination.path)
                    alert.addButton(withTitle: L("openDownloads"))
                    alert.addButton(withTitle: L("cancel"))
                    if alert.runModal() == .alertFirstButtonReturn {
                        NSWorkspace.shared.activateFileViewerSelecting([destination])
                    }
                }
            } catch {
                self.finishUpdate(title: L("updateFailed"), message: error.localizedDescription)
            }
        }.resume()
    }

    private func finishUpdate(title: String, message: String) {
        DispatchQueue.main.async {
            self.settingsUpdateButton?.isEnabled = true
            self.settingsUpdateButton?.title = L("checkUpdates")
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.runModal()
        }
    }
    @objc private func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = AppDelegate(); app.delegate = delegate
app.run()
