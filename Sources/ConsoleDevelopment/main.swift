/// Test code here
import Command

final class StrictCommand: Command {
    var arguments: [CommandArgument] {
        return []
    }
    
    var options: [CommandOption] {
        return [.flag(name: "release")]
    }
    
    var help: [String] {
        return []
    }
    
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        print(context.excess)
        return context.container.future()
    }
    
    
}

final class LaxCommand: Command {
    var arguments: [CommandArgument] {
        return []
    }
    
    var options: [CommandOption] {
        return [.flag(name: "release")]
    }
    
    var help: [String] {
        return []
    }
    
    var isStrict: Bool {
        return false
    }
    
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        print(context.excess)
        return context.container.future()
    }
}

final class TestCommands: CommandGroup {
    var commands: Commands {
        return [
            "lax": LaxCommand(),
            "strict": StrictCommand()
        ]
    }
    
    var options: [CommandOption] {
        return []
    }
    
    var help: [String] {
        return []
    }
    
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        return context.container.future()
    }
}


let console = Terminal()
let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let container = BasicContainer(config: .init(), environment: .development, services: .init(), on: elg.next())
try console.run(TestCommands(), input: &container.environment.commandInput, on: container).wait()
