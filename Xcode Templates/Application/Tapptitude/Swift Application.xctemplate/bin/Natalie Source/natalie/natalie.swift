//#!/usr/bin/env xcrun -sdk macosx swift

//
// Natalie - Storyboard Generator Script
//
// Generate swift file based on storyboard files
//
// Usage:
// natalie.swift Main.storyboard > Storyboards.swift
// natalie.swift path/toproject/with/storyboards > Storyboards.swift
//
// Licence: MIT
// Author: Marcin Krzyżanowski http://blog.krzyzanowskim.com
//

//MARK: SWXMLHash
//
//  SWXMLHash.swift
//
//  Copyright (c) 2014 David Mohundro
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

//MARK: Extensions

private extension String {
    func trimAllWhitespacesAndSpecialCharacters() -> String {
        let invalidCharacters = CharacterSet.alphanumerics.inverted
        let x = self.components(separatedBy: invalidCharacters)
        return x.joined(separator: "")
    }
}

private func SwiftRepresentationForString(_ string: String, capitalizeFirstLetter: Bool = false, doNotShadow: String? = nil) -> String {
    var str =  string.trimAllWhitespacesAndSpecialCharacters()
    if capitalizeFirstLetter {
        str = String(str.uppercased().unicodeScalars.prefix(1) + str.unicodeScalars.suffix(str.unicodeScalars.count - 1))
    }
    if str == doNotShadow {
        str = str + "_"
    }
    return str
}

//MARK: Parser

let rootElementName = "SWXMLHash_Root_Element"

/// Simple XML parser.
open class SWXMLHash {
    /**
     Method to parse XML passed in as a string.
     
     - parameter xml: The XML to be parsed
     
     - returns: An XMLIndexer instance that is used to look up elements in the XML
     */
    class open func parse(_ xml: String) -> XMLIndexer {
        return parse((xml as NSString).data(using: String.Encoding.utf8.rawValue)!)
    }
    
    /**
     Method to parse XML passed in as an NSData instance.
     
     - parameter xml: The XML to be parsed
     
     - returns: An XMLIndexer instance that is used to look up elements in the XML
     */
    class open func parse(_ data: Data) -> XMLIndexer {
        let parser = XMLParser()
        return parser.parse(data)
    }
    
    class open func lazy(_ xml: String) -> XMLIndexer {
        return lazy((xml as NSString).data(using: String.Encoding.utf8.rawValue)!)
    }
    
    class open func lazy(_ data: Data) -> XMLIndexer {
        let parser = LazyXMLParser()
        return parser.parse(data)
    }
}

struct Stack<T> {
    var items = [T]()
    mutating func push(_ item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
    mutating func removeAll() {
        items.removeAll(keepingCapacity: false)
    }
    func top() -> T {
        return items[items.count - 1]
    }
}

class LazyXMLParser: NSObject, XMLParserDelegate {
    override init() {
        super.init()
    }
    
    var root = XMLElement(name: rootElementName)
    var parentStack = Stack<XMLElement>()
    var elementStack = Stack<String>()
    
    var data: Data?
    var ops: [IndexOp] = []
    
    func parse(_ data: Data) -> XMLIndexer {
        self.data = data
        return XMLIndexer(self)
    }
    
    func startParsing(_ ops: [IndexOp]) {
        // clear any prior runs of parse... expected that this won't be necessary, but you never know
        parentStack.removeAll()
        root = XMLElement(name: rootElementName)
        parentStack.push(root)
        
        self.ops = ops
        let parser = Foundation.XMLParser(data: data!)
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        
        elementStack.push(elementName)
        
        if !onMatch() {
            return
        }
        let currentNode = parentStack.top().addElement(elementName, withAttributes: attributeDict as NSDictionary)
        parentStack.push(currentNode)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !onMatch() {
            return
        }
        
        let current = parentStack.top()
        if current.text == nil {
            current.text = ""
        }
        
        parentStack.top().text! += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let match = onMatch()
        
        elementStack.pop()
        
        if match {
            parentStack.pop()
        }
    }
    
    func onMatch() -> Bool {
        // we typically want to compare against the elementStack to see if it matches ops, *but*
        // if we're on the first element, we'll instead compare the other direction.
        if elementStack.items.count > ops.count {
            return elementStack.items.starts(with: ops.map { $0.key })
        }
        else {
            return ops.map { $0.key }.starts(with: elementStack.items)
        }
    }
}

/// The implementation of NSXMLParserDelegate and where the parsing actually happens.
class XMLParser: NSObject, XMLParserDelegate {
    override init() {
        super.init()
    }
    
    var root = XMLElement(name: rootElementName)
    var parentStack = Stack<XMLElement>()
    
    func parse(_ data: Data) -> XMLIndexer {
        // clear any prior runs of parse... expected that this won't be necessary, but you never know
        parentStack.removeAll()
        
        parentStack.push(root)
        
        let parser = Foundation.XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        return XMLIndexer(root)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        
        let currentNode = parentStack.top().addElement(elementName, withAttributes: attributeDict as NSDictionary)
        parentStack.push(currentNode)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let current = parentStack.top()
        if current.text == nil {
            current.text = ""
        }
        
        parentStack.top().text! += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        parentStack.pop()
    }
}

open class IndexOp {
    var index: Int
    let key: String
    
    init(_ key: String) {
        self.key = key
        self.index = -1
    }
    
    func toString() -> String {
        if index >= 0 {
            return key + " " + index.description
        }
        
        return key
    }
}

open class IndexOps {
    var ops: [IndexOp] = []
    
    let parser: LazyXMLParser
    
    init(parser: LazyXMLParser) {
        self.parser = parser
    }
    
    func findElements() -> XMLIndexer {
        parser.startParsing(ops)
        let indexer = XMLIndexer(parser.root)
        var childIndex = indexer
        for op in ops {
            childIndex = childIndex[op.key]
            if op.index >= 0 {
                childIndex = childIndex[op.index]
            }
        }
        ops.removeAll(keepingCapacity: false)
        return childIndex
    }
    
    func stringify() -> String {
        var s = ""
        for op in ops {
            s += "[" + op.toString() + "]"
        }
        return s
    }
}

/// Returned from SWXMLHash, allows easy element lookup into XML data.
public enum XMLIndexer: Sequence {
    case element_(XMLElement)
    case list([XMLElement])
    case stream(IndexOps)
    case error(NSError)
    
    /// The underlying XMLElement at the currently indexed level of XML.
    public var element: XMLElement? {
        get {
            switch self {
            case .element_(let elem):
                return elem
            case .stream(let ops):
                let list = ops.findElements()
                return list.element
            default:
                return nil
            }
        }
    }
    
    /// All elements at the currently indexed level
    public var all: [XMLIndexer] {
        get {
            switch self {
            case .list(let list):
                var xmlList = [XMLIndexer]()
                for elem in list {
                    xmlList.append(XMLIndexer(elem))
                }
                return xmlList
            case .element_(let elem):
                return [XMLIndexer(elem)]
            case .stream(let ops):
                let list = ops.findElements()
                return list.all
            default:
                return []
            }
        }
    }
    
    /// All child elements from the currently indexed level
    public var children: [XMLIndexer] {
        get {
            var list = [XMLIndexer]()
            for elem in all.map({ $0.element! }) {
                for elem in elem.children {
                    list.append(XMLIndexer(elem))
                }
            }
            return list
        }
    }
    
    /**
     Allows for element lookup by matching attribute values.
     
     - parameter attr: should the name of the attribute to match on
     - parameter _: should be the value of the attribute to match on
     
     - returns: instance of XMLIndexer
     */
    public func withAttr(_ attr: String, _ value: String) -> XMLIndexer {
        let attrUserInfo = [NSLocalizedDescriptionKey: "XML Attribute Error: Missing attribute [\"\(attr)\"]"]
        let valueUserInfo = [NSLocalizedDescriptionKey: "XML Attribute Error: Missing attribute [\"\(attr)\"] with value [\"\(value)\"]"]
        switch self {
        case .stream(let opStream):
            opStream.stringify()
            let match = opStream.findElements()
            return match.withAttr(attr, value)
        case .list(let list):
            if let elem = list.filter({ $0.attributes[attr] == value }).first {
                return .element_(elem)
            }
            return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: valueUserInfo))
        case .element_(let elem):
            if let attr = elem.attributes[attr] {
                if attr == value {
                    return .element_(elem)
                }
                return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: valueUserInfo))
            }
            return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: attrUserInfo))
        default:
            return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: attrUserInfo))
        }
    }
    
    /**
     Initializes the XMLIndexer
     
     - parameter _: should be an instance of XMLElement, but supports other values for error handling
     
     - returns: instance of XMLIndexer
     */
    public init(_ rawObject: AnyObject) {
        switch rawObject {
        case let value as XMLElement:
            self = .element_(value)
        case let value as LazyXMLParser:
            self = .stream(IndexOps(parser: value))
        default:
            self = .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: nil))
        }
    }
    
    /**
     Find an XML element at the current level by element name
     
     - parameter key: The element name to index by
     
     - returns: instance of XMLIndexer to match the element (or elements) found by key
     */
    public subscript(key: String) -> XMLIndexer {
        get {
            let userInfo = [NSLocalizedDescriptionKey: "XML Element Error: Incorrect key [\"\(key)\"]"]
            switch self {
            case .stream(let opStream):
                let op = IndexOp(key)
                opStream.ops.append(op)
                return .stream(opStream)
            case .element_(let elem):
                let match = elem.children.filter({ $0.name == key })
                if match.count > 0 {
                    if match.count == 1 {
                        return .element_(match[0])
                    }
                    else {
                        return .list(match)
                    }
                }
                return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            default:
                return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            }
        }
    }
    
    /**
     Find an XML element by index within a list of XML Elements at the current level
     
     - parameter index: The 0-based index to index by
     
     - returns: instance of XMLIndexer to match the element (or elements) found by key
     */
    public subscript(index: Int) -> XMLIndexer {
        get {
            let userInfo = [NSLocalizedDescriptionKey: "XML Element Error: Incorrect index [\"\(index)\"]"]
            switch self {
            case .stream(let opStream):
                opStream.ops[opStream.ops.count - 1].index = index
                return .stream(opStream)
            case .list(let list):
                if index <= list.count {
                    return .element_(list[index])
                }
                return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            case .element_(let elem):
                if index == 0 {
                    return .element_(elem)
                }
                else {
                    return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
                }
            default:
                return .error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            }
        }
    }
    
    typealias GeneratorType = XMLIndexer
    
    public func makeIterator() -> IndexingIterator<[XMLIndexer]> {
        return all.makeIterator()
    }
}

/// XMLIndexer extensions
extension XMLIndexer {
    /// True if a valid XMLIndexer, false if an error type
    public var boolValue: Bool {
        get {
            switch self {
            case .error:
                return false
            default:
                return true
            }
        }
    }
}

extension XMLIndexer: CustomStringConvertible {
    public var description: String {
        get {
            switch self {
            case .list(let list):
                return list.map { $0.description }.joined(separator: "\n")
            case .element_(let elem):
                if elem.name == rootElementName {
                    return elem.children.map { $0.description }.joined(separator: "\n")
                }
                
                return elem.description
            default:
                return ""
            }
        }
    }
}

/// Models an XML element, including name, text and attributes
open class XMLElement {
    /// The name of the element
    open let name: String
    /// The inner text of the element, if it exists
    open var text: String?
    /// The attributes of the element
    open var attributes = [String:String]()
    
    var children = [XMLElement]()
    var count: Int = 0
    var index: Int
    
    /**
     Initialize an XMLElement instance
     
     - parameter name: The name of the element to be initialized
     
     - returns: a new instance of XMLElement
     */
    init(name: String, index: Int = 0) {
        self.name = name
        self.index = index
    }
    
    /**
     Adds a new XMLElement underneath this instance of XMLElement
     
     - parameter name: The name of the new element to be added
     - parameter withAttributes: The attributes dictionary for the element being added
     
     - returns: The XMLElement that has now been added
     */
    func addElement(_ name: String, withAttributes attributes: NSDictionary) -> XMLElement {
        let element = XMLElement(name: name, index: count)
        count += 1
        
        children.append(element)
        
        for (keyAny,valueAny) in attributes {
            let key = keyAny as! String
            let value = valueAny as! String
            element.attributes[key] = value
        }
        
        return element
    }
}

extension XMLElement: CustomStringConvertible {
    public var description:String {
        get {
            var attributesStringList = [String]()
            if !attributes.isEmpty {
                for (key, val) in attributes {
                    attributesStringList.append("\(key)=\"\(val)\"")
                }
            }
            
            var attributesString = attributesStringList.joined(separator: " ")
            if (!attributesString.isEmpty) {
                attributesString = " " + attributesString
            }
            
            if children.count > 0 {
                var xmlReturn = [String]()
                xmlReturn.append("<\(name)\(attributesString)>")
                for child in children {
                    xmlReturn.append(child.description)
                }
                xmlReturn.append("</\(name)>")
                return xmlReturn.joined(separator: "\n")
            }
            
            if text != nil {
                return "<\(name)\(attributesString)>\(text!)</\(name)>"
            } else {
                return "<\(name)\(attributesString)/>"
            }
        }
    }
}

//MARK: - Natalie

//MARK: Objects
enum OS: String, CustomStringConvertible {
    case iOS = "iOS"
    case OSX = "OSX"
    
    static let allValues = [iOS, OSX]
    
    enum Runtime: String {
        case iOSCocoaTouch = "iOS.CocoaTouch"
        case MacOSXCocoa = "MacOSX.Cocoa"
        
        init(os: OS) {
            switch os {
            case iOS:
                self = .iOSCocoaTouch
            case OSX:
                self = .MacOSXCocoa
            }
        }
    }
    
    enum Framework: String {
        case UIKit = "UIKit"
        case Cocoa = "Cocoa"
        
        init(os: OS) {
            switch os {
            case iOS:
                self = .UIKit
            case OSX:
                self = .Cocoa
            }
        }
    }
    
    init(targetRuntime: String) {
        switch (targetRuntime) {
        case Runtime.iOSCocoaTouch.rawValue:
            self = .iOS
        case Runtime.MacOSXCocoa.rawValue:
            self = .OSX
        case "iOS.CocoaTouch.iPad":
            self = .iOS
        default:
            fatalError("Unsupported")
        }
    }
    
    var description: String {
        return self.rawValue
    }
    
    var framework: String {
        return Framework(os: self).rawValue
    }
    
    var targetRuntime: String {
        return Runtime(os: self).rawValue
    }
    
    var storyboardType: String {
        switch self {
        case .iOS:
            return "UIStoryboard"
        case .OSX:
            return "NSStoryboard"
        }
    }
    
    var storyboardSegueType: String {
        switch self {
        case .iOS:
            return "UIStoryboardSegue"
        case .OSX:
            return "NSStoryboardSegue"
        }
    }
    
    var storyboardControllerTypes: [String] {
        switch self {
        case .iOS:
            return ["UIViewController"]
        case .OSX:
            return ["NSViewController", "NSWindowController"]
        }
    }
    
    var storyboardControllerReturnType: String {
        switch self {
        case .iOS:
            return "UIViewController"
        case .OSX:
            return "AnyObject" // NSViewController or NSWindowController
        }
    }
    
    var storyboardControllerSignatureType: String {
        switch self {
        case .iOS:
            return "ViewController"
        case .OSX:
            return "Controller" // NSViewController or NSWindowController
        }
    }
    
    var storyboardInstantiationInfo: [(String /* Signature type */, String /* Return type */)] {
        switch self {
        case .iOS:
            return [("ViewController", "UIViewController")]
        case .OSX:
            return [("WindowController", "NSWindowController"), ("ViewController", "NSViewController")]
        }
    }
    
    var viewType: String {
        switch self {
        case .iOS:
            return "UIView"
        case .OSX:
            return "NSView"
        }
    }
    
    var resuableViews: [String]? {
        switch self {
        case .iOS:
            return ["UICollectionReusableView", "UITableViewCell"]
        case .OSX:
            return nil
        }
    }
    
    func controllerTypeForElementName(_ name: String) -> String? {
        switch self {
        case .iOS:
            switch name {
            case "viewController":
                return "UIViewController"
            case "navigationController":
                return "UINavigationController"
            case "tableViewController":
                return "UITableViewController"
            case "tabBarController":
                return "UITabBarController"
            case "splitViewController":
                return "UISplitViewController"
            case "pageViewController":
                return "UIPageViewController"
            case "collectionViewController":
                return "UICollectionViewController"
            case "exit", "viewControllerPlaceholder":
                return nil
            default:
                assertionFailure("Unknown controller element: \(name)")
                return nil
            }
        case .OSX:
            switch name {
            case "viewController":
                return "NSViewController"
            case "windowController":
                return "NSWindowController"
            case "pagecontroller":
                return "NSPageController"
            case "tabViewController":
                return "NSTabViewController"
            case "splitViewController":
                return "NSSplitViewController"
            case "exit", "viewControllerPlaceholder":
                return nil
            default:
                assertionFailure("Unknown controller element: \(name)")
                return nil
            }
        }
    }
    
}

class XMLObject {
    
    let xml: XMLIndexer
    let name: String
    
    init(xml: XMLIndexer) {
        self.xml = xml
        self.name = xml.element!.name
    }
    
    func searchAll(_ attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        return searchAll(self.xml, attributeKey: attributeKey, attributeValue: attributeValue)
    }
    
    func searchAll(_ root: XMLIndexer, attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {
            
            for childAtLevel in child.all {
                if let attributeValue = attributeValue {
                    if let element = childAtLevel.element, element.attributes[attributeKey] == attributeValue {
                        result += [childAtLevel]
                    }
                } else if let element = childAtLevel.element, element.attributes[attributeKey] != nil {
                    result += [childAtLevel]
                }
                
                if let found = searchAll(childAtLevel, attributeKey: attributeKey, attributeValue: attributeValue) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }
    
    func searchNamed(_ name: String) -> [XMLIndexer]? {
        return self.searchNamed(self.xml, name: name)
    }
    
    func searchNamed(_ root: XMLIndexer, name: String) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {
            
            for childAtLevel in child.all {
                if let elementName = childAtLevel.element?.name, elementName == name {
                    result += [child]
                }
                if let found = searchNamed(childAtLevel, name: name) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }
    
    func searchById(_ id: String) -> XMLIndexer? {
        return searchAll("id", attributeValue: id)?.first
    }
}

class Scene: XMLObject {
    
    lazy var viewController: ViewController? = {
        if let vcs = self.searchAll("sceneMemberID", attributeValue: "viewController"), let vc = vcs.first {
            return ViewController(xml: vc)
        }
        return nil
    }()
    
    lazy var segues: [Segue]? = {
        return self.searchNamed("segue")?.map { Segue(xml: $0) }
    }()
    
    lazy var customModule: String? = self.viewController?.customModule
    lazy var customModuleProvider: String? = self.viewController?.customModuleProvider
}

class ViewController: XMLObject {
    
    lazy var customClass: String? = self.xml.element?.attributes["customClass"]
    lazy var customModuleProvider: String? = self.xml.element?.attributes["customModuleProvider"]
    lazy var storyboardIdentifier: String? = self.xml.element?.attributes["storyboardIdentifier"]
    lazy var customModule: String? = self.xml.element?.attributes["customModule"]
    
    lazy var reusables: [Reusable]? = {
        if let reusables = self.searchAll(self.xml, attributeKey: "reuseIdentifier"){
            return reusables.map { Reusable(xml: $0) }
        }
        return nil
    }()
}

class Segue: XMLObject {
    let kind: String
    let identifier: String?
    lazy var destination: String? = self.xml.element?.attributes["destination"]
    
    override init(xml: XMLIndexer) {
        self.kind = xml.element!.attributes["kind"]!
        if let id = xml.element?.attributes["identifier"], id.characters.count > 0 {self.identifier = id}
        else                                                                            {self.identifier = nil}
        super.init(xml: xml)
    }
    
}

class Reusable: XMLObject {
    
    let kind: String
    lazy var reuseIdentifier: String? = self.xml.element?.attributes["reuseIdentifier"]
    lazy var customClass: String? = self.xml.element?.attributes["customClass"]
    
    
    override init(xml: XMLIndexer) {
        kind = xml.element!.name
        super.init(xml: xml)
    }
}

class Storyboard: XMLObject {
    
    let version: String
    lazy var os:OS = {
        guard let targetRuntime = self.xml["document"].element?.attributes["targetRuntime"] else {
            return OS.iOS
        }
        
        return OS(targetRuntime: targetRuntime)
    }()
    
    lazy var initialViewControllerClass: String? = {
        if let initialViewControllerId = self.xml["document"].element?.attributes["initialViewController"],
            let xmlVC = self.searchById(initialViewControllerId)
        {
            let vc = ViewController(xml: xmlVC)
            if let customClassName = vc.customClass {
                return customClassName
            }
            
            if let controllerType = self.os.controllerTypeForElementName(vc.name) {
                return controllerType
            }
        }
        return nil
    }()
    
    lazy var scenes: [Scene] = {
        guard let scenes = self.searchAll(self.xml, attributeKey: "sceneID") else {
            return []
        }
        
        return scenes.map { Scene(xml: $0) }
    }()
    
    lazy var customModules: [String] = self.scenes.filter{ $0.customModule != nil && $0.customModuleProvider == nil  }.map{ $0.customModule! }
    
    override init(xml: XMLIndexer) {
        self.version = xml["document"].element!.attributes["version"]!
        super.init(xml: xml)
    }
    
    func processStoryboard(_ storyboardName: String, os: OS) {
        print("")
        print("    struct \(storyboardName): Storyboard {")
        print("")
        print("        static let identifier = \"\(storyboardName)\"")
        print("")
        print("        static var storyboard: \(os.storyboardType) {")
        print("            return \(os.storyboardType)(name: self.identifier, bundle: nil)")
        print("        }")
        
        let hasItentifiers = self.scenes.filter({$0.viewController?.storyboardIdentifier != nil}).count > 0
        if hasItentifiers {
        // print identifier enum
            print("")
            print("        enum \(storyboardName)Identifier: String {")
            for scene in self.scenes {
                if let viewController = scene.viewController, let storyboardIdentifier = viewController.storyboardIdentifier,
                    let controllerClass = (viewController.customClass ?? os.controllerTypeForElementName(viewController.name)) {
            print("            case \(storyboardIdentifier) = \"\(storyboardIdentifier)\"")
                }
            }
            print("        }")
        }
        
        
        
        if let initialViewControllerClass = self.initialViewControllerClass {
            let cast = (initialViewControllerClass == os.storyboardControllerReturnType ? (os == OS.iOS ? "!" : "") : " as! \(initialViewControllerClass)")
            print("")
            print("        static func instantiateInitial\(os.storyboardControllerSignatureType)() -> \(initialViewControllerClass) {")
            print("            return self.storyboard.instantiateInitial\(os.storyboardControllerSignatureType)()\(cast)")
            print("        }")
        }
        for (signatureType, returnType) in os.storyboardInstantiationInfo {
            let cast = (returnType == os.storyboardControllerReturnType ? "" : " as! \(returnType)")
            print("")
            print("        static func instantiate\(signatureType)(identifier: String) -> \(returnType) {")
            print("            return self.storyboard.instantiate\(signatureType)(withIdentifier: identifier)\(cast)")
            print("        }")
            
//            print("")
//            print("        static func instantiateViewController<T: \(returnType) where T: IdentifiableProtocol>(type: T.Type) -> T? {")
//            print("            return self.storyboard.instantiateViewController(type)")
//            print("        }")
            
        }
//        for scene in self.scenes {
//            if let viewController = scene.viewController, storyboardIdentifier = viewController.storyboardIdentifier {
//                let controllerClass = (viewController.customClass ?? os.controllerTypeForElementName(viewController.name)!)
//                print("")
//                print("        static func instantiate\(SwiftRepresentationForString(storyboardIdentifier, capitalizeFirstLetter: true))() -> \(controllerClass) {")
//                print("            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)WithIdentifier(\"\(storyboardIdentifier)\") as! \(controllerClass)")
//                print("        }")
                
//                print("")
//                print("        static func instantiateViewController(type: \(controllerClass)) -> \(controllerClass) {")
//                print("            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)WithIdentifier(\"\(storyboardIdentifier)\") as! \(controllerClass)")
//                print("        }")
//                
//                print("")
//                print("        static func instantiateViewController() -> \(controllerClass) {")
//                print("            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)WithIdentifier(\"\(storyboardIdentifier)\") as! \(controllerClass)")
//                print("        }")
//            }
//        }
        print("    }")
    }
    
    func processViewControllers() {
        for scene in self.scenes {
            if let viewController = scene.viewController {
                if let customClass = viewController.customClass {
                    print("")
                    print("//MARK: - \(customClass)")
                    
                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        print("extension \(os.storyboardSegueType) {")
                        print("    func selection() -> \(customClass).Segue? {")
                        print("        if let identifier = self.identifier {")
                        print("            return \(customClass).Segue(rawValue: identifier)")
                        print("        }")
                        print("        return nil")
                        print("    }")
                        print("}")
                        print("")
                    }
                    
                    //                    if let storyboardIdentifier = viewController.storyboardIdentifier {
                    //                        print("extension \(customClass): IdentifiableProtocol { ")
                    //                        if viewController.customModule != nil {
                    //                            print("    var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }")
                    //                        } else {
                    //                            print("    public var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }")
                    //                        }
                    //                        print("    static var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }")
                    //                        print("}")
                    //                        print("")
                    //                    }
                    
                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        print("extension \(customClass) { ")
                        print("")
                        print("    enum Segue: String, CustomStringConvertible, SegueProtocol {")
                        for segue in segues {
                            if let identifier = segue.identifier
                            {
                                print("        case \(SwiftRepresentationForString(identifier)) = \"\(identifier)\"")
                            }
                        }
                        print("")
                        print("        var kind: SegueKind? {")
                        print("            switch (self) {")
                        var needDefaultSegue = false
                        for segue in segues {
                            if let identifier = segue.identifier {
                                print("            case .\(SwiftRepresentationForString(identifier)):")
                                print("                return SegueKind(rawValue: \"\(segue.kind)\")")
                            } else {
                                needDefaultSegue = true
                            }
                        }
                        if needDefaultSegue {
                            print("            default:")
                            print("                assertionFailure(\"Invalid value\")")
                            print("                return nil")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var destination: \(self.os.storyboardControllerReturnType).Type? {")
                        print("            switch (self) {")
                        var needDefaultDestination = false
                        for segue in segues {
                            if let identifier = segue.identifier, let destination = segue.destination,
                                let destinationElement = searchById(destination)?.element,
                                let destinationClass = (destinationElement.attributes["customClass"] ?? os.controllerTypeForElementName(destinationElement.name))
                            {
                                print("            case .\(SwiftRepresentationForString(identifier)):")
                                print("                return \(destinationClass).self")
                            } else {
                                needDefaultDestination = true
                            }
                        }
                        if needDefaultDestination {
                            print("            default:")
                            print("                assertionFailure(\"Unknown destination\")")
                            print("                return nil")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var identifier: String? { return self.description } ")
                        print("        var description: String { return self.rawValue }")
                        print("    }")
                        print("")
                        print("}")
                    }
                    
                    if let reusables = viewController.reusables?.filter({ return $0.reuseIdentifier != nil }), reusables.count > 0 {
                        
                        print("extension \(customClass) { ")
                        print("")
                        print("    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {")
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                print("        case \(SwiftRepresentationForString(identifier, doNotShadow: reusable.customClass)) = \"\(identifier)\"")
                            }
                        }
                        print("")
                        print("        var kind: ReusableKind? {")
                        print("            switch (self) {")
                        var needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                print("            case .\(SwiftRepresentationForString(identifier, doNotShadow: reusable.customClass)):")
                                print("                return ReusableKind(rawValue: \"\(reusable.kind)\")")
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            print("            default:")
                            print("                preconditionFailure(\"Invalid value\")")
                            print("                break")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var viewType: \(self.os.viewType).Type? {")
                        print("            switch (self) {")
                        needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier, let customClass = reusable.customClass {
                                print("            case .\(SwiftRepresentationForString(identifier, doNotShadow: reusable.customClass)):")
                                print("                return \(customClass).self")
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            print("            default:")
                            print("                return nil")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var storyboardIdentifier: String? { return self.description } ")
                        print("        var description: String { return self.rawValue }")
                        print("    }")
                        print("")
                        print("}\n")
                    }
                }
            }
        }
    }
}



class StoryboardInstantion {
    struct StoryboardInfo {
        var storyboardName: String
        var storyboardIdentifier: String
    }
    
    var storyboards: [String : [String]] = [:]
    var controllerClass: String!
    
    var isOverriding = false
}

func processStoryboardInstantiation(_ storyboards: [StoryboardFile], os: OS) {
    var instaDict = [String: StoryboardInstantion]()
    
    for file in storyboards {
        let storyboardName = file.storyboardName
        
        for scene in file.storyboard.scenes {
            if let viewController = scene.viewController, let storyboardIdentifier = viewController.storyboardIdentifier,
                let controllerClass = (viewController.customClass ?? os.controllerTypeForElementName(viewController.name)) {
                
                var item = instaDict[controllerClass]
                if item == nil {
                    item = StoryboardInstantion()
                    item!.controllerClass = controllerClass
                    
                    instaDict[controllerClass] = item!
                }
                
                // apend new identifier
                var identifiers = item?.storyboards[storyboardName] ?? []
                identifiers.append(storyboardIdentifier)
                item?.storyboards[storyboardName] = identifiers
            }
        }
    }
    
    for (_, value) in instaDict {
        let controllerClass = value.controllerClass!
        
        print("")
        print("extension \(controllerClass) { ")
        
        for (storyboardName, identifiers) in value.storyboards {
            if identifiers.count == 1 {
                for storyboardIdentifier in identifiers {
                    print("    static func instantiateFrom\(storyboardName)Storyboard() -> \(controllerClass) {")
                    print("        return Storyboards.\(storyboardName).storyboard.instantiateViewController(withIdentifier: \"\(storyboardIdentifier)\") as! \(controllerClass)")
                    print("    }")
                }
            } else {
                print("")
                print("    enum \(storyboardName)Storyboard: String {")
                for storyboardIdentifier in identifiers {
                    print("        case \(storyboardIdentifier) = \"\(storyboardIdentifier)\"")
                }
                print("    }")
                
                print("")
                print("    static func instantiateFrom\(storyboardName)Storyboard(identifier: \(storyboardName)Storyboard) -> \(controllerClass) {")
                print("        return Storyboards.\(storyboardName).storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as! \(controllerClass)")
                print("    }")
            }
        }
        
        print("}")
        print("")
    }
    
    //    for file in storyboards {
    //        let storyboardName = file.storyboardName
    //
    //        for scene in file.storyboard.scenes {
    //            if let viewController = scene.viewController, storyboardIdentifier = viewController.storyboardIdentifier {
    //                let controllerClass = (viewController.customClass ?? os.controllerTypeForElementName(viewController.name)!)
    //
    //                print("")
    //                print("extension \(controllerClass) { ")
    //                print("    static func instantiateFromStoryboard() -> \(controllerClass) {")
    //                print("        return Storyboards.\(storyboardName).storyboard.instantiateViewControllerWithIdentifier(\"\(storyboardIdentifier)\") as! \(controllerClass)")
    //                print("    }")
    //                print("}")
    //                print("")
    //            }
    //        }
    //    }
}

class StoryboardFile {
    let data: Data
    let storyboardName: String
    let storyboard: Storyboard
    
    init(filePath: String) {
        self.data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        self.storyboardName = ((filePath as NSString).lastPathComponent as NSString).deletingPathExtension
        self.storyboard = Storyboard(xml:SWXMLHash.parse(self.data))
    }
}


//MARK: Functions

func findStoryboards(_ rootPath: String, suffix: String) -> [String]? {
    var result = Array<String>()
    let fm = FileManager.default
    if let paths = fm.subpaths(atPath: rootPath) {
        let storyboardPaths = paths.filter({ return $0.hasSuffix(suffix)})
        // result = storyboardPaths
        for p in storyboardPaths {
            result.append((rootPath as NSString).appendingPathComponent(p))
        }
    }
    return result.count > 0 ? result : nil
}

func processStoryboards(_ storyboards: [StoryboardFile], os: OS) {
    
    print("//")
    print("// Autogenerated by Natalie - Storyboard Generator Script.")
    print("// http://blog.krzyzanowskim.com")
    print("//")
    print("")
    print("import \(os.framework)")
//    let modules = storyboards.flatMap{ $0.storyboard.customModules }
//    for module in Set<String>(modules) {
//        print("import \(module)")
//    }
    print("")
    
    print("//MARK: - Storyboards")
    
    print("")
    print("extension \(os.storyboardType) {")
    for (signatureType, returnType) in os.storyboardInstantiationInfo {
        print("    func instantiateViewController<T: \(returnType)>(type: T.Type) -> T? where T: IdentifiableProtocol {")
        print("        let instance = type.init()")
        print("        if let identifier = instance.storyboardIdentifier {")
        print("            return self.instantiate\(signatureType)(withIdentifier: identifier) as? T")
        print("        }")
        print("        return nil")
        print("    }")
        print("}")
        print("")
    }
    
    print("")
    print("protocol Storyboard {")
    print("    static var storyboard: \(os.storyboardType) { get }")
    print("    static var identifier: String { get }")
    print("}")
    print("")
    
    print("struct Storyboards {")
    for file in storyboards {
        file.storyboard.processStoryboard(file.storyboardName, os: os)
    }
    print("}")
    print("")
    
    processStoryboardInstantiation(storyboards, os: os)
    
    print("//MARK: - ReusableKind")
    print("enum ReusableKind: String, CustomStringConvertible {")
    print("    case TableViewCell = \"tableViewCell\"")
    print("    case CollectionViewCell = \"collectionViewCell\"")
    print("")
    print("    var description: String { return self.rawValue }")
    print("}")
    print("")
    
    print("//MARK: - SegueKind")
    print("enum SegueKind: String, CustomStringConvertible {    ")
    print("    case Relationship = \"relationship\" ")
    print("    case Show = \"show\"                 ")
    print("    case Presentation = \"presentation\" ")
    print("    case Embed = \"embed\"               ")
    print("    case Unwind = \"unwind\"             ")
    print("    case Push = \"push\"                 ")
    print("    case Modal = \"modal\"               ")
    print("    case Popover = \"popover\"           ")
    print("    case Replace = \"replace\"           ")
    print("    case Custom = \"custom\"             ")
    print("")
    print("    var description: String { return self.rawValue } ")
    print("}")
    print("")
    print("//MARK: - IdentifiableProtocol")
    print("")
    print("public protocol IdentifiableProtocol: Equatable {")
    print("    var storyboardIdentifier: String? { get }")
    print("}")
    print("")
    print("//MARK: - SegueProtocol")
    print("")
    print("public protocol SegueProtocol {")
    print("    var identifier: String? { get }")
    print("}")
    print("")
    
    print("public func ==<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {")
    print("    return lhs.identifier == rhs.identifier")
    print("}")
    print("")
    print("public func ~=<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {")
    print("    return lhs.identifier == rhs.identifier")
    print("}")
    print("")
    print("public func ==<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {")
    print("    return lhs.identifier == rhs")
    print("}")
    print("")
    print("public func ~=<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {")
    print("    return lhs.identifier == rhs")
    print("}")
    print("")
    print("public func ==<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {")
    print("    return lhs == rhs.identifier")
    print("}")
    print("")
    print("public func ~=<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {")
    print("    return lhs == rhs.identifier")
    print("}")
    print("")
    
    print("//MARK: - ReusableViewProtocol")
    print("public protocol ReusableViewProtocol: IdentifiableProtocol {")
    print("    var viewType: \(os.viewType).Type? { get }")
    print("}")
    print("")
    
    print("public func ==<T: ReusableViewProtocol, U: ReusableViewProtocol>(lhs: T, rhs: U) -> Bool {")
    print("    return lhs.storyboardIdentifier == rhs.storyboardIdentifier")
    print("}")
    print("")
    
    print("//MARK: - Protocol Implementation")
    print("extension \(os.storyboardSegueType): SegueProtocol {")
    print("}")
    print("")
    
    if let reusableViews = os.resuableViews {
        for reusableView in reusableViews {
            print("extension \(reusableView): ReusableViewProtocol {")
            print("    public var viewType: UIView.Type? { return type(of: self) }")
            print("    public var storyboardIdentifier: String? { return self.reuseIdentifier }")
            print("}")
            print("")
        }
    }
    
    for controllerType in os.storyboardControllerTypes {
        print("//MARK: - \(controllerType) extension")
        print("extension \(controllerType) {")
        print("    func performSegue<T: SegueProtocol>(_ segue: T, sender: AnyObject?) {")
        print("        if let identifier = segue.identifier {")
        print("            performSegue(withIdentifier: identifier, sender: sender)")
        print("        }")
        print("    }")
        print("")
        print("    func performSegue<T: SegueProtocol>(segue: T) {")
        print("        performSegue(segue, sender: nil)")
        print("    }")
        print("}")
        print("")
    }
    
    if os == OS.iOS {
        //        print("//MARK: - UICollectionView")
        //        print("")
        //        print("extension UICollectionView {")
        //        print("")
        //        print("    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UICollectionViewCell? {")
        //        print("        if let identifier = reusable.storyboardIdentifier {")
        //        print("            return dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: forIndexPath)")
        //        print("        }")
        //        print("        return nil")
        //        print("    }")
        //        print("")
        //        print("    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {")
        //        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        //        print("            registerClass(type, forCellWithReuseIdentifier: identifier)")
        //        print("        }")
        //        print("    }")
        //        print("")
        //        print("    func dequeueReusableSupplementaryViewOfKind<T: ReusableViewProtocol>(elementKind: String, withReusable reusable: T, forIndexPath: NSIndexPath!) -> UICollectionReusableView? {")
        //        print("        if let identifier = reusable.storyboardIdentifier {")
        //        print("            return dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: identifier, forIndexPath: forIndexPath)")
        //        print("        }")
        //        print("        return nil")
        //        print("    }")
        //        print("")
        //        print("    func registerReusable<T: ReusableViewProtocol>(reusable: T, forSupplementaryViewOfKind elementKind: String) {")
        //        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        //        print("            registerClass(type, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)")
        //        print("        }")
        //        print("    }")
        //        print("}")
        
        //        print("//MARK: - UITableView")
        //        print("")
        //        print("extension UITableView {")
        //        print("")
        //        print("    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UITableViewCell? {")
        //        print("        if let identifier = reusable.storyboardIdentifier {")
        //        print("            return dequeueReusableCellWithIdentifier(identifier, forIndexPath: forIndexPath)")
        //        print("        }")
        //        print("        return nil")
        //        print("    }")
        //        print("")
        //        print("    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {")
        //        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        //        print("            registerClass(type, forCellReuseIdentifier: identifier)")
        //        print("        }")
        //        print("    }")
        //        print("")
        //        print("    func dequeueReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) -> UITableViewHeaderFooterView? {")
        //        print("        if let identifier = reusable.storyboardIdentifier {")
        //        print("            return dequeueReusableHeaderFooterViewWithIdentifier(identifier)")
        //        print("        }")
        //        print("        return nil")
        //        print("    }")
        //        print("")
        //        print("    func registerReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) {")
        //        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        //        print("             registerClass(type, forHeaderFooterViewReuseIdentifier: identifier)")
        //        print("        }")
        //        print("    }")
        //        print("}")
        //        print("")
    }
    
    for file in storyboards {
        file.storyboard.processViewControllers()
    }
    
}

//MARK: MAIN()


