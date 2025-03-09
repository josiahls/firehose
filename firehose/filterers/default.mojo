# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.filterers.common import LoggerFilter


@value
struct DefaultLoggerFilter(LoggerFilter):
    """
    DefaultLoggerFilter: Standard log level-based filter.
    
    This is the default filter implementation that passes or blocks log messages
    based on their numeric level. Messages with a level below the filter's
    configured level are dropped.
    
    The filter applies a simple threshold rule:
    - If message level >= filter level: Message passes (returns True)
    - If message level < filter level: Message blocked (returns False)
    
    Example:
    ```
    # Create a filter at WARNING level (30)
    var filter = DefaultLoggerFilter("app_filter", LOG_LEVELS['WARNING'])
    
    # These will pass
    filter.filter(LOG_LEVELS['WARNING'], "Warning message")  # Level 30, passes
    filter.filter(LOG_LEVELS['ERROR'], "Error message")      # Level 40, passes
    
    # These will be blocked
    filter.filter(LOG_LEVELS['DEBUG'], "Debug message")      # Level 10, blocked
    filter.filter(LOG_LEVELS['INFO'], "Info message")        # Level 20, blocked
    ```
    """
    
    var name: String
    """
    Name of the filter instance, useful for debugging or management.
    """
    
    var level: Int
    """
    The threshold level for this filter. Messages with a level below this
    value will be filtered out (not logged).
    
    Standard level values:
    - 0: TRACE
    - 10: DEBUG
    - 20: INFO
    - 30: WARNING
    - 40: ERROR
    - 50: CRITICAL
    """

    fn __init__(out self, name: String, level: Int):
        """
        Initialize a new DefaultLoggerFilter.
        
        Args:
            name: Identifier for this filter instance.
            level: Threshold level - messages below this level will be filtered out.

        Example:
        ```
        # Filter that only allows WARNING and higher messages
        var filter = DefaultLoggerFilter("prod_filter", LOG_LEVELS['WARNING'])
        ```
        """
        self.name = name
        self.level = level

    fn filter(self, level: Int, message: String) -> Bool:
        """
        Filter messages based on their level.
        
        Args:
            level: The numeric level of the message.
            message: The content of the log message (unused in this filter).

        Returns:
            Bool: True if the message should be logged, False if it should be dropped

        Messages with a level less than the filter's level will be dropped.
        Messages with a level greater than or equal to the filter's level will pass.
        
        Note that the message content is not used in filtering decisions for
        the default filter - only the level is considered.
        """
        return level >= self.level
