# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.formatters.common import LoggerFormatter


@value
struct DefaultLoggerFormatter(LoggerFormatter):
    var name: String
    var level: Int
    var format_string: String

    fn __init__(out self, name: String, level: Int):
        self.name = name
        self.level = level
        self.format_string = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

    fn format(self, message: String) -> String:
        return message
