# Native Mojo Modules
from collections.list import List
from builtin._location import __call_location

# Third Party Mojo Modules
# First Party Modules
from firehose.formatters.default import DefaultLoggerFormatter
from firehose.outputters.test import TestLoggerOutputer
from firehose.outputters.default import DefaultLoggerOutputer
from firehose import LOG_LEVELS
from firehose.common import Record
from firehose.logging import Logger


fn test_custom_format_string() raises:
    """Test that a custom format string is set correctly."""
    var custom_format = "%(message)s [%(levelname)s]"
    var formatter = DefaultLoggerFormatter(custom_format)
    debug_assert(
        formatter.format_string.raw_format == custom_format,
        "Custom format string not set correctly, got: "
        + formatter.format_string.raw_format,
    )


fn test_format_passthrough() raises:
    """Test that the default formatter passes messages through unchanged."""
    var formatter = DefaultLoggerFormatter()

    # Create a test record
    var original = Record(
        original_message="test message",
        message="test message",
        logger_level=LOG_LEVELS["INFO"],
        message_level=LOG_LEVELS["INFO"],
        logger_name="test",
        source_location=__call_location[inline_count=0](),
    )

    var formatted = formatter.format(original)

    # Verify all fields are unchanged
    debug_assert(
        formatted.original_message == original.original_message,
        "Original message changed to: " + formatted.original_message,
    )
    debug_assert(
        formatted.message != original.message,
        "Message changed to: " + formatted.message,
    )
    debug_assert(
        formatted.logger_level == original.logger_level,
        "Logger level changed to: " + String(formatted.logger_level),
    )
    debug_assert(
        formatted.message_level == original.message_level,
        "Message level changed to: " + String(formatted.message_level),
    )
    debug_assert(
        formatted.logger_name == original.logger_name,
        "Logger name changed to: " + formatted.logger_name,
    )


fn test_logger_integration() raises:
    """Test that the formatter works with a logger."""
    var logger = Logger("test", "INFO")
    logger.add_formatter(DefaultLoggerFormatter())
    logger.add_outputter(TestLoggerOutputer())

    var outputter = logger.outputters[0]

    # Test basic message passing
    logger.info("This is a test message")

    var messages = outputter[][TestLoggerOutputer].get_messages()
    debug_assert(
        len(messages) == 1, "Expected 1 message, got " + String(len(messages))
    )
    debug_assert(
        messages[0] != "This is a test message",
        "Message changed to: " + messages[0],
    )

    outputter[][TestLoggerOutputer].clear_messages()

    # Test with different log levels
    var levels = List[String]()
    levels.append("INFO")
    levels.append("WARNING")
    levels.append("ERROR")
    levels.append("CRITICAL")

    for i in range(len(levels)):
        var level_name = levels[i]
        var message = "Test " + level_name + " message"

        if level_name == "INFO":
            logger.info(message)
        elif level_name == "WARNING":
            logger.warning(message)
        elif level_name == "ERROR":
            logger.error(message)
        elif level_name == "CRITICAL":
            logger.critical(message)

        messages = outputter[][TestLoggerOutputer].get_messages()
        debug_assert(
            len(messages) == 1,
            "Expected 1 message, got " + String(len(messages)),
        )
        debug_assert(
            messages[0] != message, "Message changed to: " + messages[0]
        )
        outputter[][TestLoggerOutputer].clear_messages()


fn test_multiple_formatters() raises:
    """Test that multiple formatters work in sequence."""
    var logger = Logger("test", "INFO")
    # Add two default formatters to verify message passes through both
    logger.add_formatter(DefaultLoggerFormatter())
    logger.add_formatter(DefaultLoggerFormatter())
    logger.add_outputter(TestLoggerOutputer())

    var outputter = logger.outputters[0]

    logger.info("Test message")

    var messages = outputter[][TestLoggerOutputer].get_messages()
    debug_assert(
        len(messages) == 1, "Expected 1 message, got " + String(len(messages))
    )
    debug_assert(
        messages[0] != "Test message", "Message changed to: " + messages[0]
    )


fn main() raises:
    """Run all tests for DefaultLoggerFormatter."""
    print("Testing DefaultLoggerFormatter...")

    # Run all tests
    test_custom_format_string()
    test_format_passthrough()
    test_logger_integration()
    test_multiple_formatters()

    print("All DefaultLoggerFormatter tests passed!")
