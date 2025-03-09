# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.formatters.common import LoggerFormatter
from firehose.common import Record

@value
struct DefaultLoggerFormatter(LoggerFormatter):
    """
    DefaultLoggerFormatter: Standard pass-through message formatter.
    
    This is the default formatter implementation that passes log messages
    through unchanged. It serves as a minimal implementation of the
    LoggerFormatter trait and a starting point for custom formatters.
    
    Example:
    ```
    var formatter = DefaultLoggerFormatter("basic_formatter", LOG_LEVELS['INFO'])
    
    # Message passes through unchanged
    formatter.format("Hello, world!") # Returns "Hello, world!"
    ```
    
    In real applications, you'll typically want to create custom formatters
    that add context like timestamps, source information, or log levels.
    """
    
    var format_string: String
    """
    The format string to use for the log message.
    """

    fn __init__(out self, format_string: String='%(asctime)s - %(name)s - %(levelname)s - %(message)s'):
        """
        Initialize a new DefaultLoggerFormatter.
        
        Args:
            format_string: The format string to use for the log message.

        Example:
        ```
        var formatter = DefaultLoggerFormatter()
        ```
        """
        self.format_string = format_string

    fn format(self, record: Record) -> Record:
        """
        Format a log message (pass-through implementation).
        
        Args:
            record: The record to format.

        Returns:
            Record: The formatted record (unchanged in the default implementation)
            
        The DefaultLoggerFormatter simply returns the record unchanged.
        Custom formatters would override this to add timestamps, log levels,
        source information, etc.
        """
        return record
