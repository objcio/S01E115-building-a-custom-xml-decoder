import Foundation

let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<account href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44">
  <adjustments href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44/adjustments"/>
  <account_balance href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44/balance"/>
  <billing_info href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44/billing_info"/>
  <invoices href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44/invoices"/>
  <shipping_addresses href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44/shipping_addresses"/>
  <subscriptions href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44/subscriptions"/>
  <transactions href="https://domain.recurly.com/v2/accounts/06a5313b-7972-48a9-a0a9-3d7d741afe44/transactions"/>
  <account_code>06a5313b-7972-48a9-a0a9-3d7d741afe44</account_code>
  <state>active</state>
  <username nil="nil"></username>
  <email>mail@floriankugler.com</email>
  <cc_emails nil="nil"></cc_emails>
  <first_name>Florian</first_name>
  <last_name>Kugler</last_name>
  <company_name nil="nil"></company_name>
  <vat_number nil="nil"></vat_number>
  <preferred_locale nil="nil"></preferred_locale>
  <tax_exempt type="boolean">false</tax_exempt>
  <address>
    <address1 nil="nil"></address1>
    <address2 nil="nil"></address2>
    <city nil="nil"></city>
    <state nil="nil"></state>
    <zip nil="nil"></zip>
    <country nil="nil"></country>
    <phone nil="nil"></phone>
  </address>
  <accept_language nil="nil"></accept_language>
  <hosted_login_token>dd73cd5be174906d6d5cb7ec01e2581c</hosted_login_token>
  <created_at type="datetime">2016-12-13T19:14:32Z</created_at>
  <updated_at type="datetime">2018-08-13T19:14:32Z</updated_at>
  <closed_at nil="nil"></closed_at>
  <has_live_subscription type="boolean">true</has_live_subscription>
  <has_active_subscription type="boolean">true</has_active_subscription>
  <has_future_subscription type="boolean">false</has_future_subscription>
  <has_canceled_subscription type="boolean">false</has_canceled_subscription>
  <has_past_due_invoice type="boolean">false</has_past_due_invoice>
  <has_paused_subscription type="boolean">false</has_paused_subscription>
</account>
"""

struct Account: Codable {
    enum State: String, Codable {
        case active, canceled
    }
    var state: State
    var email: String
    var company_name: String?
}

extension XMLElement {
    func child(for key: CodingKey) -> XMLElement? {
        return (children ?? []).first(where: { $0.name == key.stringValue }).flatMap({ $0 as? XMLElement })
    }
}

final class RecurlyXMLDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    let element: XMLElement
    init(_ element: XMLElement) {
        self.element = element
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KDC(element))
    }
    
    struct KDC<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var codingPath: [CodingKey] = []
        var allKeys: [Key] = []
        
        let element: XMLElement
        init(_ element: XMLElement) {
            self.element = element
        }
        
        func contains(_ key: Key) -> Bool {
            return element.child(for: key) != nil
        }

        func child(for key: CodingKey) throws -> XMLElement {
            guard let child = element.child(for: key) else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "TODO"))
            }
            return child
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            let child = try self.child(for: key)
            return child.attribute(forName: "nil") != nil
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            fatalError()
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            let child = try self.child(for: key)
            return child.stringValue! // todo verify that it's never nil
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            fatalError()
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            fatalError()
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            fatalError()
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            fatalError()
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            fatalError()
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            fatalError()
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            fatalError()
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            fatalError()
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            fatalError()
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            fatalError()
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            fatalError()
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            fatalError()
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            let el = try child(for: key)
            let decoder = RecurlyXMLDecoder(el)
            return try T(from: decoder)
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError()
        }
        
        func superDecoder() throws -> Decoder {
            fatalError()
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError()
        }
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SVDC(element)
    }
    
    struct SVDC: SingleValueDecodingContainer {
        var codingPath: [CodingKey] = []
        let element: XMLElement
        
        init(_ element: XMLElement) {
            self.element = element
        }
        
        func decodeNil() -> Bool {
            fatalError()
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            fatalError()
        }
        
        func decode(_ type: String.Type) throws -> String {
            return element.stringValue! // todo check "never nil" assumption
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            fatalError()
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            fatalError()
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            fatalError()
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            fatalError()
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            fatalError()
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            fatalError()
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            fatalError()
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            fatalError()
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            fatalError()
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            fatalError()
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            fatalError()
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            fatalError()
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            fatalError()
        }
    }
}

let document = try XMLDocument(xmlString: xml, options: [])
let root = document.rootElement()!
let decoder = RecurlyXMLDecoder(root)
let account = try Account(from: decoder)
print(account)

