import ConsoleKit
import NIO

let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let terminal = Terminal(on: elg)

terminal.info("Hello World")
