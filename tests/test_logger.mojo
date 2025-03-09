"""
Unit tests for the Firehose logging library.

This file demonstrates how to test code that uses logging with the
TestLoggerOutputer to capture and verify log messages.
"""

# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.logging import Logger
from firehose import (
    DefaultLoggerFilter, DefaultLoggerFormatter, DefaultLoggerOutputer
)


fn test_visual_output() raises:
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



# Main function to run the tests
fn main() raises:
    print("Running Firehose logger tests...")
    test_visual_output()
    print("All Firehose tests completed successfully.") 