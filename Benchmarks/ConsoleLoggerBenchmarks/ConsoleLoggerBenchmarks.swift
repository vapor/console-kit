import Benchmark
import ConsoleLogger
import Logging

let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.peakMemoryResident, .mallocCountTotal],
        thresholds: [
            .peakMemoryResident: .init(
                // Tolerate up to 4% of difference compared to the threshold.
                relative: [.p90: 4],
                // Tolerate up to one million bytes of difference compared to the threshold.
                absolute: [.p90: 1_100_000]
            ),
            .mallocCountTotal: .init(
                // Tolerate up to 1% of difference compared to the threshold.
                relative: [.p90: 1],
                // Tolerate up to 2 malloc calls of difference compared to the threshold.
                absolute: [.p90: 2]
            ),
        ]
    )

    Benchmark(
        "Logging",
        configuration: .init(
            setup: {
                ConsoleLogger.bootstrap(
                    metadataProvider: .init {
                        ["provided1": "from metadata provider", "provided2": "another metadata provider"]
                    }
                )
            }
        )
    ) { benchmark in
        var logger = Logger(label: "codes.vapor.console")
        logger.logLevel = .trace
        logger[metadataKey: "value"] = "one"

        for _ in benchmark.scaledIterations {
            logger.info(
                "Info",
                metadata: ["from-log": "value", "also-from-log": "other"]
            )
        }
    }

    Benchmark(
        "LoggerFragmentBuilder",
        configuration: .init(
            setup: {
                ConsoleLogger.bootstrap(
                    metadataProvider: .init {
                        ["provided1": "from metadata provider", "provided2": "another metadata provider"]
                    }
                ) {
                    // This is the default logger fragment, but built using LoggerFragmentBuilder
                    SpacedFragment {
                        LabelFragment().maxLevel(.trace)
                        LevelFragment()
                        MessageFragment()
                        MetadataFragment()
                        SourceLocationFragment().maxLevel(.debug)
                    }
                }
            }
        )
    ) { benchmark in
        var logger = Logger(label: "codes.vapor.console")
        logger.logLevel = .trace
        logger[metadataKey: "value"] = "one"

        for _ in benchmark.scaledIterations {
            logger.info(
                "Info",
                metadata: ["from-log": "value", "also-from-log": "other"]
            )
        }
    }
}
