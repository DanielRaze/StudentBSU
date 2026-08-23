extension Array where Element == ExamModel {
    
    var upcomingTests: [ExamModel] {
        filter { $0.mark == nil && $0.type == .test }
    }
    
    var upcomingExams: [ExamModel] {
        filter { $0.mark == nil && $0.type == .exam }
    }
    
    var passedTests: [ExamModel] {
        filter { $0.mark != nil && $0.type == .test }
    }
    
    var passedExams: [ExamModel] {
        filter { $0.mark != nil && $0.type == .exam }
    }
}
