# Native Mojo Modules
from memory import ArcPointer

# Third Party Mojo Modules
# First Party Modules
from firehose.common import Record


trait LoggerFormatter(Copyable & Movable):
    """
    LoggerFormatter: Interface for formatting log messages.

    This trait defines the contract for objects that transform log messages
    before they are output. Formatters can add context, timestamps, color codes,
    or any other transformation to the message string.

    Implementing a custom formatter:
    ```
    @value
    struct TimestampFormatter(LoggerFormatter):
        var name: String

        fn __init__(out self, name: String):
            self.name = name

        fn format(self, message: String) -> String:
            # Add a timestamp to the message
            # In real code you would use proper time functions
            return "[2023-03-15 14:32:10] " + message
    ```

    The Logger will apply each formatter in sequence to each message.
    The output of one formatter becomes the input to the next formatter
    in the chain.
    """

    fn format(self, record: Record) -> Record:
        """
        Transforms a log message before output.

        Args:
            record: The record to be formatted, which could be either
                    the original message or the output from a previous formatter.

        Returns:
            Record: The transformed/formatted record

        This method is called by the Logger for each message being logged after
        it has passed all filters. Formatters are applied in sequence, with the
        output of one formatter becoming the input to the next.
        """
        ...
