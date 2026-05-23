//
//  MessageFeedback.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import FoundationModels

// MARK: - MessageFeedback

@Generable(description: "Portuguese language feedback for a learner's message")
struct MessageFeedback {
    @Guide(description: "How natural the message sounds in Carioca context, 0-10")
    var contextScore: Int

    @Guide(description: "Grammar correctness score, 0-10")
    var grammarScore: Int

    @Guide(description: "The user's message corrected, or same if already correct")
    var correctedMessage: String

    @Guide(description: "Brief explanation in English of what was corrected and why")
    var explanationEN: String

    @Guide(description: "Whether the message feels authentically Carioca")
    var feelsCarioca: Bool

    @Guide(description: "Up to 2 nicer/more natural alternatives the user could have said")
    var nicerAlternatives: [String]
}
