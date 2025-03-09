# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.filterers.common import LoggerFilter


@value
struct DefaultLoggerFilter(LoggerFilter):
    var name: String
    var level: Int

    fn filter(self, level: Int, message: String) -> Bool:
        return level >= self.level
