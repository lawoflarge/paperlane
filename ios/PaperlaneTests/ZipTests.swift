import Testing
import Foundation
@testable import Paperlane

struct ZipTests {
    @Test func crc32MatchesStandardVector() {
        // Canonical CRC-32 check value of the ASCII string "123456789".
        #expect(Zip.crc32(Data("123456789".utf8)) == 0xCBF4_3926)
    }

    @Test func archiveStartsWithLocalHeaderAndEndsWithEOCD() {
        let zip = Zip.archive([(name: "a.txt", data: Data("hello".utf8))])
        #expect(Array(zip.prefix(4)) == [0x50, 0x4B, 0x03, 0x04])              // PK\x03\x04
        #expect(Array(zip.suffix(22).prefix(4)) == [0x50, 0x4B, 0x05, 0x06])  // EOCD (no comment)
        #expect(zip.range(of: Data("a.txt".utf8)) != nil)
        #expect(zip.range(of: Data("hello".utf8)) != nil)
    }
}
