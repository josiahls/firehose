# Firehose

## Overview
> Note: This library is experimental and is dependent on the continued improvement
of the mojo langauge. Consider this alpha.

Firehose is a logging library for Mojo.

## Examples

### Basic Logging with Custom Formatting
```mojo
from firehose.logging import Logger
from firehose import (
    DefaultLoggerFilter, DefaultLoggerFormatter, DefaultLoggerOutputer
)


fn main() raises:
    """Just run the logs and print them to visually validate the format."""
    var logger = Logger("test", "INFO")
    # Also change the logger level via environemntal variable:
    # _ = os.setenv("FIREHOSE_LEVEL", "INFO", overwrite=True)
    # Test all of the format fields
    logger.add_formatter_copy(
        DefaultLoggerFormatter(
            '%(file)s:%(file_name)s:%(line)s:%(column)s %(logger_name)s - %(message_level)s - %(message_level_name)s - %(message_level_name_short)s: %(original_message)s'
        )
    )
    logger.add_outputter_copy(DefaultLoggerOutputer())
    logger.add_filter_copy(DefaultLoggerFilter())

    logger.trace("Test trace message")
    logger.debug("Test debug message")
    logger.info("Test message")
    logger.warning("Test warning message")
    logger.error("Test error message")
    logger.critical("Test critical message")

```

This will output messages with detailed context including:
- File, line, and column information
- Logger name
- Message level (numeric and text)
- Original message

The format string can be customized to include any combination of these fields.

### Caveats:
- Custom filters, outputs, and formatters need to be directly added to the library itself in each module's init file at: `firehose/__init__.mojo`. Ideally we would just have a filter register function, or skip the need for variants altogether. 
- Duplicates the `Variant` struct for each module type to get union-like behavior. Ideas to get around this are welcome.
- Not optimized for performance. I currently update it as the need arises. 