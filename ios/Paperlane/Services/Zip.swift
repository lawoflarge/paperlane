import Foundation

/// Minimal STORED (no-compression) ZIP writer — enough to assemble a valid `.docx`
/// (OOXML) container fully on-device with no third-party dependency.
enum Zip {
    static func archive(_ entries: [(name: String, data: Data)]) -> Data {
        var output = Data()
        var central = Data()
        var offsets: [Int] = []

        for entry in entries {
            let nameBytes = Array(entry.name.utf8)
            let crc = crc32(entry.data)
            let size = UInt32(entry.data.count)
            offsets.append(output.count)
            output.append(le32: 0x0403_4b50)            // local file header sig
            output.append(le16: 20)                     // version needed
            output.append(le16: 0)                      // flags
            output.append(le16: 0)                      // method = stored
            output.append(le16: 0)                      // mod time
            output.append(le16: 0)                      // mod date
            output.append(le32: crc)
            output.append(le32: size)                   // compressed size
            output.append(le32: size)                   // uncompressed size
            output.append(le16: UInt16(nameBytes.count))
            output.append(le16: 0)                      // extra length
            output.append(contentsOf: nameBytes)
            output.append(entry.data)
        }

        for (index, entry) in entries.enumerated() {
            let nameBytes = Array(entry.name.utf8)
            let crc = crc32(entry.data)
            let size = UInt32(entry.data.count)
            central.append(le32: 0x0201_4b50)           // central dir header sig
            central.append(le16: 20)                    // version made by
            central.append(le16: 20)                    // version needed
            central.append(le16: 0)                     // flags
            central.append(le16: 0)                     // method
            central.append(le16: 0)                     // time
            central.append(le16: 0)                     // date
            central.append(le32: crc)
            central.append(le32: size)
            central.append(le32: size)
            central.append(le16: UInt16(nameBytes.count))
            central.append(le16: 0)                     // extra
            central.append(le16: 0)                     // comment
            central.append(le16: 0)                     // disk start
            central.append(le16: 0)                     // internal attrs
            central.append(le32: 0)                     // external attrs
            central.append(le32: UInt32(offsets[index]))
            central.append(contentsOf: nameBytes)
        }

        let centralOffset = output.count
        output.append(central)
        output.append(le32: 0x0605_4b50)                // EOCD sig
        output.append(le16: 0)                          // disk no
        output.append(le16: 0)                          // disk with cd
        output.append(le16: UInt16(entries.count))
        output.append(le16: UInt16(entries.count))
        output.append(le32: UInt32(central.count))
        output.append(le32: UInt32(centralOffset))
        output.append(le16: 0)                          // comment length
        return output
    }

    private static let table: [UInt32] = {
        (0..<256).map { index -> UInt32 in
            var c = UInt32(index)
            for _ in 0..<8 { c = (c & 1) != 0 ? 0xEDB8_8320 ^ (c >> 1) : c >> 1 }
            return c
        }
    }()

    static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in data {
            crc = table[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
        }
        return crc ^ 0xFFFF_FFFF
    }
}

private extension Data {
    mutating func append(le16 value: UInt16) {
        append(UInt8(value & 0xFF))
        append(UInt8((value >> 8) & 0xFF))
    }
    mutating func append(le32 value: UInt32) {
        append(UInt8(value & 0xFF))
        append(UInt8((value >> 8) & 0xFF))
        append(UInt8((value >> 16) & 0xFF))
        append(UInt8((value >> 24) & 0xFF))
    }
}
