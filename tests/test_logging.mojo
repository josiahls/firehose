# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose import logging



alias logger = logging.Logger('test_logging')


# Example test usage
fn test_logger() raises:
    var logger = logging.Logger("test", logging.LOG_LEVELS['INFO'])
    var test_outputer = logging.TestLoggerOutputer("test_output", logging.LOG_LEVELS['INFO'])
    logger.add_output(test_outputer)
    
    logger.info("Test message 1")
    logger.info("Test message 2")
    
    # Get all collected messages
    var messages = test_outputer.get_messages()
    debug_assert(len(messages) == 2)
    debug_assert(messages[0] == "Test message 1")
    debug_assert(messages[1] == "Test message 2")
    
    # Clear messages for next test
    test_outputer.clear_messages()


fn test_logging() raises:
    test_logger = logging.Logger.get_default_logger('test_logging', 'DEBUG')

    test_logger.info('Hello, World!')
    test_logger.debug('Hello, World!')
    test_logger.critical('Hello, World!')
    test_logger.error('Hello, World!')
    test_logger.warning('Hello, World!')
    test_logger.trace('Hello, World!')





fn main() raises:
    test_logger()
    test_logging()
    print('succeeded')

