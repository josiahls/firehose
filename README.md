# Firehose

A familiar logging system for Mojo.

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
    # Test all of the format fields
    logger.add_formatter_copy(
        DefaultLoggerFormatter(
            '%(file)s:%(line)s:%(column)s %(logger_name)s - %(message_level)s - %(message_level_name)s - %(message_level_name_short)s: %(original_message)s'
        )
    )
    logger.add_outputter_copy(DefaultLoggerOutputer())
    logger.add_filter_copy(DefaultLoggerFilter()) # Default is INFO level

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