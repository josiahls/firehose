# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.filterers.common import LoggerFilter
from firehose.common import Record


@value
struct DefaultLoggerFilter(LoggerFilter):
    """
    DefaultLoggerFilter: Standard log level-based filter.

    This filter implements a simple threshold-based filtering mechanism that passes
    or blocks log messages based on their numeric level compared to the filter's
    configured level.

    The filter applies a simple rule:
    - If message_level >= filter.level: Message passes (returns True)
    - If message_level < filter.level: Message is blocked (returns False)

    Example:
    ```
    # Create a filter
    var filter = DefaultLoggerFilter()

    # Create a record with INFO level message
    var info_record = Record(
        ..., 
        message_level=LOG_LEVELS["INFO"], 
        logger_level=LOG_LEVELS["INFO"],
        ...
    )
    filter.filter(info_record)  # Returns True (passes)

    # Create a record with DEBUG level message
    var debug_record = Record(
        ...,
        message_level=LOG_LEVELS["DEBUG"],
        logger_level=LOG_LEVELS["INFO"],
        ...
    )
    filter.filter(debug_record)  # Returns False (filtered out)
    ```

    This filter is typically added to a Logger to control which messages
    are processed based on their severity level.
    """
    fn __init__(out self):
        pass

    fn filter(self, record: Record) -> Bool:
        """
        Filter messages based on their level.

        Args:
            record: The record to filter, containing message_level and other properties.

        Returns:
            Bool: True if the message should be logged, False if it should be dropped.

        Messages with a level less than the filter's level will be dropped.
        Messages with a level greater than or equal to the filter's level will pass.

        Note that the message content is not used in filtering decisions for
        the default filter - only the level is considered.
        """
        return record.message_level >= record.logger_level
