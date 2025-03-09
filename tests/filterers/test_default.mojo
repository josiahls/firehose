# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.filterers.default import DefaultLoggerFilter
from firehose import LOG_LEVELS
from firehose.common import Record


fn test_filter_below_level():
    """Test that messages below the filter level are rejected."""
    var filter = DefaultLoggerFilter("test_filter", LOG_LEVELS['INFO'])
    
    # Create a DEBUG level message (10) which is below INFO (20)
    var record = Record(
        original_message="debug message",
        message="debug message",
        logger_level=LOG_LEVELS['INFO'],
        message_level=LOG_LEVELS['DEBUG'],
        logger_name="test"
    )
    
    # Should be filtered out since DEBUG < INFO
    debug_assert(not filter.filter(record), "DEBUG message should be filtered out by INFO filter")


fn test_filter_at_level():
    """Test that messages at the filter level are accepted."""
    var filter = DefaultLoggerFilter("test_filter", LOG_LEVELS['INFO'])
    
    # Create an INFO level message (20)
    var record = Record(
        original_message="info message",
        message="info message",
        logger_level=LOG_LEVELS['INFO'],
        message_level=LOG_LEVELS['INFO'],
        logger_name="test"
    )
    
    # Should pass since INFO == INFO
    debug_assert(filter.filter(record), "INFO message should pass INFO filter")


fn test_filter_above_level():
    """Test that messages above the filter level are accepted."""
    var filter = DefaultLoggerFilter("test_filter", LOG_LEVELS['INFO'])
    
    # Create an ERROR level message (40) which is above INFO (20)
    var record = Record(
        original_message="error message",
        message="error message",
        logger_level=LOG_LEVELS['INFO'],
        message_level=LOG_LEVELS['ERROR'],
        logger_name="test"
    )
    
    # Should pass since ERROR > INFO
    debug_assert(filter.filter(record), "ERROR message should pass INFO filter")


fn test_filter_trace_level():
    """Test that TRACE level filter accepts all messages."""
    var filter = DefaultLoggerFilter("test_filter", LOG_LEVELS['TRACE'])
    
    # Test all levels
    for level_name in ['TRACE', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']:
        var record = Record(
            original_message=level_name + " message",
            message=level_name + " message",
            logger_level=LOG_LEVELS['TRACE'],
            message_level=LOG_LEVELS[level_name],
            logger_name="test"
        )
        debug_assert(filter.filter(record), level_name + " message should pass TRACE filter")


fn test_filter_critical_level():
    """Test that CRITICAL level filter only accepts CRITICAL messages."""
    var filter = DefaultLoggerFilter("test_filter", LOG_LEVELS['CRITICAL'])
    
    # Test all levels
    for level_name in ['TRACE', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']:
        var record = Record(
            original_message=level_name + " message",
            message=level_name + " message",
            logger_level=LOG_LEVELS['CRITICAL'],
            message_level=LOG_LEVELS[level_name],
            logger_name="test"
        )
        
        if level_name == 'CRITICAL':
            debug_assert(filter.filter(record), "CRITICAL message should pass CRITICAL filter")
        else:
            debug_assert(not filter.filter(record), level_name + " message should not pass CRITICAL filter")


fn main():
    """Run all tests for DefaultLoggerFilter."""
    print("Testing DefaultLoggerFilter...")
    
    # Run all tests
    test_filter_below_level()
    test_filter_at_level()
    test_filter_above_level()
    test_filter_trace_level()
    test_filter_critical_level()
    
    print("All DefaultLoggerFilter tests passed!") 