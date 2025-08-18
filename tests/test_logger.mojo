"""
Unit tests for the Firehose logging library.

This file demonstrates how to test code that uses logging with the
TestLoggerOutputer to capture and verify log messages.
"""

# Native Mojo Modules
import os

# Third Party Mojo Modules
# First Party Modules
from firehose.logging import Logger, set_global_logger_settings
from firehose import (
    DefaultLoggerFilter,
    DefaultLoggerFormatter,
    DefaultLoggerOutputer,
)


fn test_visual_output() raises:
    """Just run the logs and print them to visually validate the format."""
    set_global_logger_settings(level=10)
    var logger = Logger.get_default_logger("test")
    # Test all of the format fields
    logger.add_formatter_copy(
        DefaultLoggerFormatter(
            "%(file)s:%(file_name)s:%(line)s:%(column)s %(logger_name)s -"
            " %(message_level)s - %(message_level_name)s -"
            " %(message_level_name_short)s: %(original_message)s"
        )
    )

    logger.trace("Test trace message")
    logger.debug("Test debug message")
    logger.info("Test message")
    logger.warning("Test warning message")
    logger.error("Test error message")
    logger.critical("Test critical message")


fn test_env_var_level() raises:
    """Test that the environment variable level is respected."""
    _ = os.setenv("FIREHOSE_LEVEL", "DEBUG", overwrite=True)
    var logger = Logger.get_default_logger("test")
    logger.debug("Test debug message")

    _ = os.setenv("FIREHOSE_LEVEL", "INFO", overwrite=True)
    logger.debug("Test debug message should not be printed")
    logger.info("Test info message")


# Main function to run the tests
fn main() raises:
    print("Running Firehose logger tests...")
    test_visual_output()
    test_env_var_level()
    print("All Firehose tests completed successfully.")
