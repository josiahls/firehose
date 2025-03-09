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
    
    var name: String
    """
    Name of the formatter instance, useful for debugging or management.
    """
    
    var level: Int
    """
    Level associated with this formatter, though not used in the default implementation.
    In custom implementations, this could be used to format messages differently
    based on their level.
    
    Standard level values:
    - 0: TRACE
    - 10: DEBUG
    - 20: INFO
    - 30: WARNING
    - 40: ERROR
    - 50: CRITICAL
    """
    var format_string: String
    """
    The format string to use for the log message.
    """

    fn __init__(out self, name: String, level: Int):
        """
        Initialize a new DefaultLoggerFormatter.
        
        Args:
            name: Identifier for this formatter instance.
            level: Level value (unused in the default implementation).

        Example:
        ```
        var formatter = DefaultLoggerFormatter("simple_formatter", LOG_LEVELS['INFO'])
        ```
        """
        self.name = name
        self.level = level
        self.format_string = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

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
