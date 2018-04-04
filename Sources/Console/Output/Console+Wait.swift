import COperatingSystem

extension Console {
    // MARK: Wait
    
    public func blockingWait(seconds: Double) {
        let factor = 1000 * 1000
        let microseconds = seconds * Double(factor)
        usleep(useconds_t(microseconds))
    }
}
