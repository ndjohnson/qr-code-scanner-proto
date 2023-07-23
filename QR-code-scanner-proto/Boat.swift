//
//  Boat.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 7/17/23.
//

import Foundation

enum BoatState {
    case notStarted
    case started
    case finished
}

class Boat : Identifiable, ObservableObject {
    var id:String
    var track:[Double] = []
    var startTime:Date = Date()
    var finishTime:Date = Date()
    var state:BoatState = .notStarted
    @Published var club:String = ""
    @Published var crew:String = ""
    
    init(id:String, x:Double) {
        self.id = id
        track.append(x)
    }
    
    init(_ id:String) {
        self.id = id
    }
    
    func detected(x:Double) -> Bool {
        track.append(x)
        return hasTraversed()
    }
    
    func hasTraversed() -> Bool {
        if track.count > 1 {
            let lastOne = track[track.count-1]
            let lastButOne = track[track.count-2]
            if ((lastButOne > 0.5) && (lastOne <= 0.5)) || ((lastButOne <= 0.5) && (lastOne > 0.5)) {
                switch state {
                case .notStarted:
                    state = .started
                case .started:
                    state = .finished
                case .finished:
                    state = .finished
                }
                return true
            }
        }
        return false
    }
    
    func start() {
        self.state = .started
        self.startTime = Date.now
    }
    
    func finish() {
        self.state = .finished
        self.finishTime = Date.now
    }
}

class Boats : ObservableObject {
    var boats:[Boat]
    
    init (_ boats:[Boat]) {
        self.boats = boats
    }
    
    func contains(boat:Boat) -> Bool {
        for b in boats {
            if b.id == boat.id {
                return true
            }
        }
        return false
    }
    
    func contains(id:String) -> Boat? {
        for b in boats {
            if b.id == id {
                return b
            }
        }
        return nil

    }
    
    func boat(forId: String) -> Boat? {
        for b in boats {
            if b.id == forId {
                return b
            }
        }
        return nil
    }
    
    func update(forId: String, crew: String? = nil, club: String? = nil) {
        for b in boats {
            if b.id == forId {
                if let crew {
                    b.crew = crew
                }
                if let club {
                    b.club = club
                }
            }
        }
    }
    
    func add(boat:Boat) {
        if !contains(boat: boat) {
            boats.append(boat)
        }
    }
    
    func detected(id:String, x:Double) -> Bool {
        if let b = contains(id: id) {
            return b.detected(x: x)
        } else {
            add(boat: Boat(id: id, x: x))
            return false
        }
    }
    
    func reset() {
        for boat in boats {
            boat.state = .notStarted
            boat.track = []
        }
    }
    
}
