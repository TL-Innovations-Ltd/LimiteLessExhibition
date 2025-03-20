//
//  StoreHistory.swift
//  Limi
//
//  Created by Mac Mini on 20/03/2025.
//
import Foundation
import Combine
import SwiftUI

typealias ByteArray = [UInt8]

struct QueueElement: Codable {
    let hub: Hub
    let byteArray: ByteArray

    func formattedByteArray() -> String {
        return byteArray.map { String(format: "0x%02X", $0) }.joined(separator: ", ")
    }
}

class StoreHistory: ObservableObject {
    @AppStorage("storeHistoryQueue") private var storedQueueData: Data = Data()
    @Published private(set) var queues: [UUID: [QueueElement]] = [:]
    private let maxQueueSize = 5

    init() {
        loadQueues()
    }

    func addElement(hub: Hub, byteArray: ByteArray) {
        let newElement = QueueElement(hub: hub, byteArray: byteArray)
        var queue = queues[hub.id] ?? []
        if queue.count >= maxQueueSize {
            queue.removeFirst()
        }
        queue.append(newElement)
        queues[hub.id] = queue
        saveQueues()
    }

    var isQueueFull: Bool {
        return queues.values.contains { $0.count >= maxQueueSize }
    }

    private func saveQueues() {
        if let data = try? JSONEncoder().encode(queues) {
            storedQueueData = data
        }
    }

    private func loadQueues() {
        if let loadedQueues = try? JSONDecoder().decode([UUID: [QueueElement]].self, from: storedQueueData) {
            queues = loadedQueues
        }
    }
}
