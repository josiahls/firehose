# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.common import Record

trait LoggerFilter(CollectionElement):
    """
    LoggerFilter: Interface for filtering log messages.
    
    This trait defines the contract for objects that decide whether log messages
    should be processed or ignored based on various criteria.
    
    Implementing a custom filter:
    ```
    @value
    struct CustomFilter(LoggerFilter):
        var name: String
        var level: Int
        var included_prefixes: List[String]
        
        fn __init__(out self, name: String, level: Int, prefixes: List[String]):
            self.name = name
            self.level = level
            self.included_prefixes = prefixes
            
        fn filter(self, record: Record) -> Bool:
            # First check message level
            if record.level < self.level:
                return False
                
            # Then check for included prefixes
            for prefix in self.included_prefixes:
                if record.message.starts_with(prefix):
                    return True
            
            return False
    ```
    
    The Logger will call the filter() method on each filter in its filter chain.
    If any filter returns False, the message will be dropped and not processed further.
    """
    
    fn filter(self, record: Record) -> Bool:
        """
        Determines whether a log message should be processed.
        
        Args:
            record: The record to filter.

        Returns:
            Bool: True if the message should be processed, False if it should be dropped
            
        This method is called by the Logger for each message being logged.
        If it returns False, the message will be dropped and not processed further.
        If it returns True, the message will be passed to the next filter in the chain
        or proceed to formatting and output if there are no more filters.
        """
        ...
