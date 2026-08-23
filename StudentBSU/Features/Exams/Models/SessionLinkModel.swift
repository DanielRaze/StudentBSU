struct SessionLinkModel {
    let text: String
    let href: String?
    let id: String?
    var target: String? = nil
    
    mutating func setTarget(target: String) {
        self.target = target
    }
}

