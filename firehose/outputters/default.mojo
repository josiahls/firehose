# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.outputters.common import LoggerOutputer
from firehose.common import Record

@value
struct DefaultLoggerOutputer(LoggerOutputer):
    """
    DefaultLoggerOutputer: Standard console output implementation.
    
    This is the default outputer implementation that sends log messages
    to the console using the built-in print() function. It provides a
    basic output mechanism suitable for simple applications and development.
    
    Example:
    ```
    var outputer = DefaultLoggerOutputer("console", LOG_LEVELS['INFO'])
    
    # Output a message to the console
    outputer.output("Hello, world!") # Prints "Hello, world!" to the console
    ```
    
    For production applications, you may want to create custom outputters
    that write to files, network services, or other destinations.
    """
    
    var name: String
    """
    Name of the outputer instance, useful for debugging or management.
    """
    
    var level: Int
    """
    Level associated with this outputer, though not used in the default implementation.
    In custom implementations, this could be used to determine output destinations
    based on message level.
    
    Standard level values:
    - 0: TRACE
    - 10: DEBUG
    - 20: INFO
    - 30: WARNING
    - 40: ERROR
    - 50: CRITICAL
    """

    fn __init__(out self, name: String, level: Int):
        """
        Initialize a new DefaultLoggerOutputer.
        
        Args:
            name: Identifier for this outputer instance.
            level: Level value (unused in the default implementation).

        Example:
        ```
        var outputer = DefaultLoggerOutputer("console", LOG_LEVELS['INFO'])
        ```
        """
        self.name = name
        self.level = level

    fn output(mut self, record: Record):
        """
        Output a log message to the console.
        
        Args:
            record: The formatted message to output.

        This method outputs the message to the console using the built-in
        print() function. The 'mut' designation is required by the trait,
        though this implementation doesn't modify its state.
        
        Note that there's no return value - output operations are performed
        for their side effects.
        """
        print(record.message)
