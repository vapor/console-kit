import Strand
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/**
    A loading bar that indicates ongoing activity.

    start() // dot moves
        Loading Item [      •  ] 

    fail()
        Loading Item [Failed]

    finish()
        Loading Item [Done]
*/
public class LoadingBar: Bar {
    var thread: Strand?
    var current: Int
    var inc: Int
    let cycles: Int
    var running: Bool

    public override init(console: ConsoleProtocol, title: String, width: Int, barStyle: ConsoleStyle, titleStyle: ConsoleStyle) {
        current = -1
        inc = 1
        cycles = width
        running = true

        super.init(console: console, title: title, width: width, barStyle: barStyle, titleStyle: titleStyle)
    }

    public override func finish(_ message: String? = nil) {
        stop()
        super.finish(message)
    }

    public override func fail(_ message: String? = nil) {
        stop()
        super.fail(message)
    }

    public override func update() {
        if current == -1 {
            current = 0
        } else {
            usleep(25 * 1000)
        }

        guard running else {
            return
        }

        super.update()
    }

    func stop() {
        running = false
        do {
            try thread?.cancel()
        } catch {
            //
        }
    }

    override var bar: String {
        current += inc
        if current == cycles || current == 0 {
            inc *= -1
        }

        var string: String = "["

        let pos = (width / cycles) * current
        for i in 0 ..< width {
            if i == pos {
                string += "•"
            } else {
                string += " "
            }
        }

        string += "]"

        return string
    }

    public func start() {
        #if !NO_ANIMATION
            do {
                thread = try Strand { [weak self] in
                    while true {
                        self?.update()
                    }
                }
            } catch {
                console.info("[Loading]")
            }
        #endif
    }

    deinit {
        finish()
    }
}
