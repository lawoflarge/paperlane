import Testing
import PDFKit
@testable import Paperlane

struct PDFEncryptorTests {

    @Test func encryptedPDFRequiresPassword() {
        let plain = PDFAssembler().assemble(images: [ImageFixtures.page("secret")])
        let encrypted = PDFEncryptor().encrypt(plain, password: "open-sesame")
        #expect(encrypted != nil)

        let doc = PDFDocument(data: encrypted!)
        #expect(doc?.isEncrypted == true)
        #expect(doc?.isLocked == true)
        #expect(doc?.unlock(withPassword: "open-sesame") == true)
    }

    @Test func emptyPasswordIsRejected() {
        let plain = PDFAssembler().assemble(images: [ImageFixtures.page("x")])
        #expect(PDFEncryptor().encrypt(plain, password: "") == nil)
    }
}
