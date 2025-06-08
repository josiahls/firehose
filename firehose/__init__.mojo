"""
Firehose: A flexible, extensible logging system for Mojo

Firehose provides a configurable logging system that allows you to:
1. Filter logs by level (TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL)
2. Format log messages using custom formatters
3. Output logs to different destinations (console, files, memory for testing)

Example usage:
```
# Import the necessary components
from firehose.logging import Logger
from firehose import LOG_LEVELS

# Create a default logger that prints to stdout with INFO level
var logger = Logger.get_default_logger("my_app")

# Log at different levels
logger.info("Application started")
logger.debug("Debug information")  # Won't show at INFO level
logger.warning("Warning message")
logger.error("Error occurred")

# Create a logger with a specific level
var debug_logger = Logger.get_default_logger("debug_module", "DEBUG")
debug_logger.debug("This debug message will be shown")
```

For testing, use the TestLoggerOutputer to capture log messages:
```
# Import the necessary components
from firehose.logging import Logger
from firehose import LOG_LEVELS, TestLoggerOutputer

# Create a logger and add a test outputter
var logger = Logger.get_default_logger("test_logger")
var test_outputter = TestLoggerOutputer("test_output", LOG_LEVELS['INFO'])
logger.add_outputter(test_outputter)

# Log some messages
logger.info("Test message 1")
logger.info("Test message 2")

# Retrieve and verify the captured messages
var messages = test_outputter.get_messages()
assert len(messages) == 2
```

API Overview:
- LOG_LEVELS: Dictionary mapping level names to their numeric values
- FilterVariant: Type for runtime-polymorphic filter objects
- FormatterVariant: Type for runtime-polymorphic formatter objects
- OutputerVariant: Type for runtime-polymorphic output objects
- DefaultLoggerFilter: Standard level-based filter implementation
- DefaultLoggerFormatter: Standard message formatter implementation
- DefaultLoggerOutputer: Standard console output implementation
- TestLoggerOutputer: Message-capturing outputter for testing
"""

# Native Mojo Modules
from utils import Variant
from collections.dict import Dict
from collections.list import List

# Third Party Mojo Modules
# First Party Modules
# Import the common types
from firehose.common import Record

# Import the different variant types
from firehose.filterers.variant import Variant as _FilterVariant
from firehose.formatters.variant import Variant as _FormatterVariant
from firehose.outputters.variant import Variant as _OutputerVariant

# Import the default implementations
from firehose.filterers.default import DefaultLoggerFilter
from firehose.formatters.default import DefaultLoggerFormatter
from firehose.outputters.default import DefaultLoggerOutputer
from firehose.outputters.test import TestLoggerOutputer
from firehose.outputters.file_logger import FileLoggerOutputer

# Define the variants
alias FilterVariant = _FilterVariant[DefaultLoggerFilter]
"""
FilterVariant: Runtime-polymorphic type for message filters.

FilterVariant objects determine whether a log message should be processed based
on criteria like log level or message content.

Default implementation:
- DefaultLoggerFilter: Filters based on message log level

Example:
```
var filter = DefaultLoggerFilter("my_filter", LOG_LEVELS['INFO'])
var filter_variant = FilterVariant(filter)
```

To create a custom filter:
1. Implement the LoggerFilter trait
2. Create an instance of your filter
3. Use it with the Logger through FilterVariant

The FilterVariant can be passed to Logger.add_filter() to install the filter.
"""

alias FormatterVariant = _FormatterVariant[DefaultLoggerFormatter]
"""
FormatterVariant: Runtime-polymorphic type for message formatters.

FormatterVariant objects transform log messages before they are output,
allowing for customization of message format, added context, etc.

Default implementation:
- DefaultLoggerFormatter: Passes through messages unchanged

Example:
```
var formatter = DefaultLoggerFormatter("my_formatter", LOG_LEVELS['INFO'])
var formatter_variant = FormatterVariant(formatter)
```

To create a custom formatter:
1. Implement the LoggerFormatter trait
2. Create an instance of your formatter
3. Use it with the Logger through FormatterVariant

The FormatterVariant can be passed to Logger.add_formatter() to install the formatter.
"""

alias OutputerVariant = _OutputerVariant[
    DefaultLoggerOutputer, TestLoggerOutputer, FileLoggerOutputer
]
"""
OutputerVariant: Runtime-polymorphic type for message outputters.

OutputerVariant objects handle the final delivery of log messages to their
destination, such as the console, a file, or an in-memory collection.

Default implementations:
- DefaultLoggerOutputer: Outputs messages to the console with print()
- TestLoggerOutputer: Stores messages in memory for testing
- FileLoggerOutputer: Outputs messages to a file
Example:
```
# Regular console output
var outputter = DefaultLoggerOutputer("console", LOG_LEVELS['INFO'])
var outputter_variant = OutputerVariant(outputter)

# Test output that captures messages
var test_outputter = TestLoggerOutputer("testing", LOG_LEVELS['DEBUG'])
var test_variant = OutputerVariant(test_outputter)
```

To create a custom outputter:
1. Implement the LoggerOutputer trait
2. Create an instance of your outputter
3. Use it with the Logger through OutputerVariant

The OutputerVariant can be passed to Logger.add_outputter() to install the outputter.
"""


# Initialize the log levels
fn _init_log_levels() -> Dict[String, Int]:
    """
    Initialize the dictionary of log levels with standard severity values.

    Returns:
        Dict[String, Int]: A dictionary mapping level names to numeric values

    Log level hierarchy (from lowest to highest priority):
    - TRACE (0): Detailed tracing information, typically for inner loops
    - DEBUG (10): Debugging information useful during development
    - INFO (20): General information about program execution
    - WARNING (30): Potential issues that don't prevent normal execution
    - ERROR (40): Errors that prevent specific operations from completing
    - CRITICAL (50): Critical failures that may cause program termination
    """
    d = Dict[String, Int]()
    d[
        "TRACE"
    ] = 0  # Typically inner loop logging statements (e.g. "Loop iter 1000")
    d[
        "DEBUG"
    ] = 10  # Noisy logging statements for debugging (e.g. "Item dump: 1,2,3...")
    d[
        "INFO"
    ] = 20  # Regular runtime information (e.g. "Executing phase 1 of 3")
    d[
        "WARNING"
    ] = 30  # Potential issues (e.g. "Skipping item 1000 due to missing data")
    d["ERROR"] = 40  # Serious issues (e.g. "Failed to parse item 1000")
    d[
        "CRITICAL"
    ] = 50  # Critical issues (e.g. "Program is unstable, shutting down")
    return d


fn _init_log_levels_numeric() -> List[Int]:
    """
    Initialize a list of all numeric log level values.

    Returns:
        List[Int]: A list containing all numeric log level values

    This is used for validation when setting log levels.
    """
    numeric_levels = List[Int]()
    for level in _init_log_levels().values():
        numeric_levels.append(level)
    return numeric_levels


fn _init_log_levels_keys() -> List[String]:
    """
    Initialize a list of all log level names.

    Returns:
        List[String]: A list containing all log level names

    This is used for validation and display purposes.
    """
    keys = List[String]()
    for key in _init_log_levels().keys():
        keys.append(key)
    return keys


# Expose log level constants for use throughout the application
alias LOG_LEVELS = _init_log_levels()
"""
LOG_LEVELS: Dictionary mapping log level names to their numeric values.

This provides a convenient way to reference log levels by name rather than by
their numeric values.

Available levels:
- TRACE (0): Extremely detailed information for tracing code execution
- DEBUG (10): Detailed information useful during development
- INFO (20): General runtime information (default level)
- WARNING (30): Indicates potential issues that don't prevent operation
- ERROR (40): Serious issues that prevent specific operations
- CRITICAL (50): Critical failures that may cause program termination

Example:
```
# Create a logger with WARNING level
var logger = Logger.get_default_logger("myapp", LOG_LEVELS['WARNING'])

# Check if a level meets a threshold
if current_level >= LOG_LEVELS['ERROR']:
    # Handle serious issues
```
"""

alias LOG_LEVELS_NUMERIC = _init_log_levels_numeric()
"""
LOG_LEVELS_NUMERIC: List of all defined numeric log level values.

This list contains all the numeric values for the defined log levels,
useful for validating level values or iterating through all levels.

Example:
```
# Check if a custom level value is valid
if custom_level in LOG_LEVELS_NUMERIC:
    # It's a standard level
else:
    # It's a custom level
```
"""

alias LOG_LEVELS_KEYS = _init_log_levels_keys()
"""
LOG_LEVELS_KEYS: List of all defined log level names.

This list contains all the string names for the defined log levels,
useful for validating level names or iterating through all levels.

Example:
```
# Print all available log levels
print("Available log levels:")
for level_name in LOG_LEVELS_KEYS:
    print(" -", level_name, "=", LOG_LEVELS[level_name])
```
"""


fn _init_log_levels_numeric_to_names() -> Dict[Int, String]:
    """
    Initialize a dictionary mapping numeric log levels to their names.

    Returns:
        Dict[Int, String]: A dictionary mapping numeric log levels to their names

    This provides a reverse mapping from numeric log levels to their corresponding
    names, useful for converting numeric levels to their textual representations.
    """
    d = Dict[Int, String]()
    for item in LOG_LEVELS.items():
        d[item.value] = item.key
    return d


alias LOG_LEVEL_NAMES_FROM_NUMERIC = _init_log_levels_numeric_to_names()
"""
LOG_LEVEL_NAMES_FROM_NUMERIC: Dictionary mapping numeric log levels to their names.

This provides a reverse mapping from numeric log levels to their corresponding

"""
