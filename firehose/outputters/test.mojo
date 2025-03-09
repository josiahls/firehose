# Native Mojo Modules
from collections.list import List
# Third Party Mojo Modules
# First Party Modules
from firehose.outputters.common import LoggerOutputer
from firehose.common import Record


@value
struct TestLoggerOutputer(LoggerOutputer):
    """
    TestLoggerOutputer: In-memory log message collector for testing.
    
    This outputter stores log messages in memory rather than outputting them
    to an external destination. This makes it ideal for use in unit tests
    where you need to verify that your code is logging the correct messages.
    
    Example:
    ```
    # Set up a logger with a test outputter
    var logger = Logger.get_default_logger("test_logger")
    var test_outputter = TestLoggerOutputer("test", LOG_LEVELS['DEBUG'])
    logger.add_output(test_outputter)
    
    # Your code that should log messages
    some_function_that_logs(logger)
    
    # Verify the logged messages
    var messages = test_outputter.get_messages()
    assert len(messages) == 2
    assert "Expected message" in messages[0]
    
    # Clear for next test
    test_outputter.clear_messages()
    ```
    
    This enables testing that your code logs appropriate messages
    without relying on console output or other external systems.
    """
    
    var messages: List[String]
    """
    List of captured log messages.
    
    This list stores all messages received by this outputter since creation
    or the last call to clear_messages(). The messages are stored in the
    order they were received.
    """
    
    var max_messages: Int
    """
    Maximum number of messages to store.
    
    This setting prevents memory issues if an excessive number of messages
    are logged. If the number of messages exceeds this limit, the oldest
    messages will be dropped.
    
    Default: 1000 messages
    """

    fn __init__(out self):
        """
        Initialize a new TestLoggerOutputer.
        
        Example:
        ```
        var test_outputter = TestLoggerOutputer()
        ```
        
        The outputter starts with an empty message list and a default
        maximum message count of 1000.
        """
        self.messages = List[String]()
        self.max_messages = 1000

    fn output(mut self, record: Record):
        """
        Capture a log message in the internal message list.
        
        Args:
            record: The log record to capture
            
        This method appends the message to the internal message list.
        The 'mut' designation is required because this method modifies
        the outputter's state.
        
        If the number of stored messages exceeds max_messages, the oldest
        message will be removed to make room for the new one.
        
        Note that there's no return value - the message is stored for
        later retrieval via get_messages().
        """
        self.messages.append(record.message)
        if len(self.messages) > self.max_messages:
            # Remove oldest message if we exceed max capacity
            _ = self.messages.pop(0)

    fn get_messages(self) -> List[String]:
        """
        Retrieve the list of captured messages.
        
        Returns:
            List[String]: A list of all messages captured since creation
                        or the last call to clear_messages()
                        
        Example:
        ```
        var messages = test_outputter.get_messages()
        for i in range(len(messages)):
            print("Message", i, ":", messages[i])
        ```
        
        This method doesn't clear the message list - use clear_messages()
        for that purpose.
        """
        return self.messages

    fn clear_messages(mut self):
        """
        Clear all captured messages from the internal list.
        
        This method resets the message list to empty, allowing for a fresh
        start in a new test case.
        
        Example:
        ```
        # After verifying messages from first test
        test_outputter.clear_messages()
        
        # Run second test
        another_function_that_logs(logger)
        
        # Verify new messages without interference from first test
        var new_messages = test_outputter.get_messages()
        ```
        
        This method requires mut access because it modifies the outputter's state.
        """
        self.messages = List[String]() 