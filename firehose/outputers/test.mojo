# Native Mojo Modules
from collections.list import List
# Third Party Mojo Modules
# First Party Modules
from firehose.outputers.common import LoggerOutputer


@value
struct TestLoggerOutputer(LoggerOutputer):
    var name: String
    var level: Int
    var messages: List[String]
    var max_messages: Int

    fn __init__(out self, name: String, level: Int):
        self.name = name
        self.level = level
        self.messages = List[String]()
        self.max_messages = 1000
    fn output(mut self, message: String):
        self.messages.append(message)
        if len(self.messages) > self.max_messages:
            print('TestLoggerOutputer: max messages reached (' + String(self.max_messages) + '), clearing messages')
            _ = self.messages.pop(0)

    fn get_messages(self) -> List[String]:
        return self.messages

    fn clear_messages(mut self):
        self.messages = List[String]() 