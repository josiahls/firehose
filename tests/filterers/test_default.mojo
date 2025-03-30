# Native Mojo Modules
from collections.list import List

# Third Party Mojo Modules
# First Party Modules
from firehose.filterers.default import DefaultLoggerFilter
from firehose.outputters.test import TestLoggerOutputer
from firehose import LOG_LEVELS
from firehose.common import Record
from firehose.logging import Logger


fn test_filter_below_level() raises:
    """Test that messages below the filter level are rejected."""
    var filter = DefaultLoggerFilter("INFO")

    # Create a DEBUG level message (10) which is below INFO (20)
    var record = Record(
        original_message="debug message",
        message="debug message",
        logger_level=LOG_LEVELS["INFO"],
        message_level=LOG_LEVELS["DEBUG"],
        logger_name="test",
    )

    # Should be filtered out since DEBUG < INFO
    debug_assert(
        not filter.filter(record),
        "DEBUG message should be filtered out by INFO filter",
    )


fn test_filter_at_level() raises:
    """Test that messages at the filter level are accepted."""
    var filter = DefaultLoggerFilter("INFO")

    # Create an INFO level message (20)
    var record = Record(
        original_message="info message",
        message="info message",
        logger_level=LOG_LEVELS["INFO"],
        message_level=LOG_LEVELS["INFO"],
        logger_name="test",
    )

    # Should pass since INFO == INFO
    debug_assert(filter.filter(record), "INFO message should pass INFO filter")


fn test_filter_above_level() raises:
    """Test that messages above the filter level are accepted."""
    var filter = DefaultLoggerFilter("INFO")

    # Create an ERROR level message (40) which is above INFO (20)
    var record = Record(
        original_message="error message",
        message="error message",
        logger_level=LOG_LEVELS["INFO"],
        message_level=LOG_LEVELS["ERROR"],
        logger_name="test",
    )

    # Should pass since ERROR > INFO
    debug_assert(filter.filter(record), "ERROR message should pass INFO filter")


fn test_filter_trace_level() raises:
    """Test that TRACE level filter accepts all messages."""
    var filter = DefaultLoggerFilter("TRACE")

    # Test all levels
    var levels = List[String]()
    levels.append("TRACE")
    levels.append("DEBUG")
    levels.append("INFO")
    levels.append("WARNING")
    levels.append("ERROR")
    levels.append("CRITICAL")

    for i in range(len(levels)):
        var level_name = levels[i]
        var record = Record(
            original_message=level_name + " message",
            message=level_name + " message",
            logger_level=LOG_LEVELS["TRACE"],
            message_level=LOG_LEVELS[level_name],
            logger_name="test",
        )
        debug_assert(
            filter.filter(record),
            level_name + " message should pass TRACE filter",
        )


fn test_filter_critical_level() raises:
    """Test that CRITICAL level filter only accepts CRITICAL messages."""
    var filter = DefaultLoggerFilter("CRITICAL")

    # Test all levels
    var levels = List[String]()
    levels.append("TRACE")
    levels.append("DEBUG")
    levels.append("INFO")
    levels.append("WARNING")
    levels.append("ERROR")
    levels.append("CRITICAL")

    for i in range(len(levels)):
        var level_name = levels[i]
        var record = Record(
            original_message=level_name + " message",
            message=level_name + " message",
            logger_level=LOG_LEVELS["CRITICAL"],
            message_level=LOG_LEVELS[level_name],
            logger_name="test",
        )

        if level_name == "CRITICAL":
            debug_assert(
                filter.filter(record),
                "CRITICAL message should pass CRITICAL filter",
            )
        else:
            debug_assert(
                not filter.filter(record),
                level_name + " message should not pass CRITICAL filter",
            )


fn test_logger_integration() raises:
    """Test that the filter works with a logger."""
    var logger = Logger("test", "DEBUG")
    logger.add_filter(DefaultLoggerFilter("DEBUG"))
    logger.add_outputter(TestLoggerOutputer())

    var outputter = logger.outputters[0]

    logger.info("This is an info message")
    logger.debug("This is a debug message")

    var messages = outputter[][TestLoggerOutputer].get_messages()
    debug_assert(len(messages) == 2)
    debug_assert(messages[0] == "This is an info message")
    debug_assert(messages[1] == "This is a debug message")

    outputter[][TestLoggerOutputer].clear_messages()

    logger.level = LOG_LEVELS["INFO"]
    logger.filterers[0][][DefaultLoggerFilter].level = LOG_LEVELS["INFO"]

    logger.info("This is an info message")
    logger.debug("This is a debug message")

    messages = outputter[][TestLoggerOutputer].get_messages()
    debug_assert(
        len(messages) == 1, "Expected 1 message, got " + String(len(messages))
    )
    debug_assert(
        messages[0] == "This is an info message",
        "Expected message to be 'This is an info message', got '"
        + messages[0]
        + "'",
    )

    outputter[][TestLoggerOutputer].clear_messages()

    # Loop through all levels testing all the supported levels
    n_levels = len(LOG_LEVELS)
    idx = 0
    for level in LOG_LEVELS:
        logger.level = LOG_LEVELS[level[]]
        logger.filterers[0][][DefaultLoggerFilter].level = LOG_LEVELS[level[]]
        logger.trace("This is a trace message")
        logger.debug("This is a debug message")
        logger.info("This is an info message")
        logger.warning("This is a warning message")
        logger.error("This is an error message")
        logger.critical("This is a critical message")

        messages = outputter[][TestLoggerOutputer].get_messages()

        n_expected = n_levels - idx

        debug_assert(
            len(messages) == n_expected,
            "Expected "
            + String(n_expected)
            + " message, got "
            + String(len(messages)),
        )
        outputter[][TestLoggerOutputer].clear_messages()

        idx += 1


fn main() raises:
    """Run all tests for DefaultLoggerFilter."""
    print("Testing DefaultLoggerFilter...")

    # Run all tests
    test_filter_below_level()
    test_filter_at_level()
    test_filter_above_level()
    test_filter_trace_level()
    test_filter_critical_level()
    test_logger_integration()

    print("All DefaultLoggerFilter tests passed!")
