# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.common import Record


trait LoggerOutputer(Copyable & Movable):
    """
    LoggerOutputer: Interface for outputting log messages.

    This trait defines the contract for objects that handle the final delivery
    of log messages to their destinations, such as the console, files,
    network services, or in-memory collections.

    Implementing a custom outputter:
    ```
    @value
    struct FileOutputer(LoggerOutputer):
        var name: String
        var file_path: String

        fn __init__(out self, name: String, file_path: String):
            self.name = name
            self.file_path = file_path

        fn output(mut self, message: String):
            # Write the message to a file
            # In real code you would have proper file handling
            print("Writing to", self.file_path, ":", message)
    ```

    The Logger will call the output() method on each outputter in its
    output chain. Each outputter receives the same formatted message.
    """

    fn output(mut self, record: Record):
        """
        Outputs a formatted log message to its destination.

        Args:
            record: The formatted record to be output

        This method is called by the Logger for each message being logged
        after it has passed all filters and been formatted by all formatters.

        The method must be mut because some outputters (like the TestLoggerOutputer)
        need to modify their state when outputting a message.

        Each outputter in the Logger's output chain receives the same formatted
        message, allowing multiple simultaneous outputs (console, file, etc.).
        """
        ...
