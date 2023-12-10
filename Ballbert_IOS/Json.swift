//
//  Json.swift
//  Ballbert_IOS
//
//  Created by Sam Liebert on 12/4/23.
//

import Foundation

func convertJSONToDictionary(_ jsonString: String) -> [String: Any]? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Something is wrong while converting JSON string to data.")
        return nil
    }

    do {
        let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        return dictionary
    } catch {
        print("Error while converting JSON data to dictionary: \(error.localizedDescription)")
        return nil
    }
}

func convertDictionaryToJSON(_ dictionary: [String: Any]) -> String? {

   guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
      print("Something is wrong while converting dictionary to JSON data.")
      return nil
   }

   guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      print("Something is wrong while converting JSON data to JSON string.")
      return nil
   }

   return jsonString
}
