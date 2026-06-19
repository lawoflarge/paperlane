import Testing
import Foundation
@testable import ScanLite

struct BusinessCardParserTests {
    @Test func parsesNamePhoneEmailOrg() {
        let text = "Jane Doe\nAcme GmbH\n+1 (415) 555-0199\njane.doe@acme.com"
        let contact = BusinessCardParser.parse(ocrText: text)
        #expect(contact.email == "jane.doe@acme.com")
        #expect(contact.fullName == "Jane Doe")
        #expect(contact.organization == "Acme GmbH")
        #expect(contact.phone?.contains("415") == true)
    }

    @Test func emptyTextHasNothing() {
        #expect(BusinessCardParser.parse(ocrText: "").hasAnything == false)
    }
}
