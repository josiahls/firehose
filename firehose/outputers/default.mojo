# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.outputers.common import LoggerOutputer


@value
struct DefaultLoggerOutputer(LoggerOutputer):
    var name: String
    var level: Int

    fn __init__(out self, name: String, level: Int):
        self.name = name
        self.level = level

    fn output(mut self, message: String):
        print(message)
