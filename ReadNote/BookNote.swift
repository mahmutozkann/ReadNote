//
//  BookNote.swift
//  ReadNote
//
//  Created by Mahmut Özkan on 19.06.2024.
//

import Foundation
import FirebaseFirestore

struct BookNote: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var author: String
    var pageNumber: String
    var quote: String
}
