//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 5/9/25.
//

import XCTest
import EssentialFeediOS

class FeedLocalizationTests: XCTestCase {

    func test_locaizationStrings_haveKeysAndValuesForAllSupporterdLocalizations()  {
        let table = "Feed"
        let presentationbundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(in: presentationbundle)
        let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)
        
        localizationBundles.forEach { (bundle, localization) in
            localizedStringKeys.forEach { key in
                let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
                
                if localizedString == key {
                    XCTFail("Missing \(language) (\(localization)) localized string for key: `\(key)`, in table: `\(table)`")
                }
            }
        }
    }

    // MARK: Helpers
    
    public typealias LocalizedBundle = (bundle: Bundle, localization: String)
    
    func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
        bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType: "lproj"),
                    let localizedBundle = Bundle(path: path) else {
                XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                return nil
            }
            return (localizedBundle, localization)
        }
    }
    
    func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
        return bundles.reduce([]) { (acc, current) in
            guard
                let path = current.bundle.path(forResource: table, ofType: "strings"),
                let strings = NSDictionary(contentsOfFile: path),
                let keys = strings.allKeys as? [String]
            else {
                XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                return acc
            }

            return acc.union(Set(keys))
        }
    }
}
