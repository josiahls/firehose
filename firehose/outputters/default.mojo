# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from firehose.outputters.common import LoggerOutputer
from firehose.common import Record

@value
struct DefaultLoggerOutputer(LoggerOutputer):
    """
    DefaultLoggerOutputer: Standard console output implementation.
    
    This is the default outputter implementation that sends log messages
    to the console using the built-in print() function. It provides a
    basic output mechanism suitable for simple applications and development.
    
    Example:
    ```
    var outputter = DefaultLoggerOutputer("console", LOG_LEVELS['INFO'])
    
    # Output a message to the console
    outputter.output("Hello, world!") # Prints "Hello, world!" to the console
    ```
    
    For production applications, you may want to create custom outputters
    that write to files, network services, or other destinations.
    """

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
