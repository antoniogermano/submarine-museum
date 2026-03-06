/*
Navy Museum

Abstract:
Navigation routes for exhibit detail views.
*/

import Foundation

enum ExhibitRoute: Hashable {
    case full(Submarine)
    case stub(Submarine)
}
