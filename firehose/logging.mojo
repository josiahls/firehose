# Native Mojo Modules
from collections.dict import Dict
from utils import Variant
# Third Party Mojo Modules
# First Party Modules
from firehose import FormatterVariant, FilterVariant, OutputerVariant, LOG_LEVELS, LOG_LEVELS_NUMERIC


@value
struct Logger:
    """
    Logger: The main entry point for the Firehose logging system.
    
    The Logger class provides methods for logging messages at different
    severity levels and manages the processing pipeline through filters, 
    formatters, and outputers.
    
    Basic usage:
    ```
    # Create a default logger with INFO level
    var logger = Logger.get_default_logger("my_app")
    
    # Log at different levels
    logger.info("Application started")
    logger.debug("Debug information")
    logger.warning("Warning message")
    logger.error("Error message")
    ```
    """
    var name:String
    """
    Name of the logger instance, used for identification in log messages.
    """
    var level:Int
    """
    The base logging level for this logger. Messages with a level below
    this value will be filtered out.
    """
    var formatters:List[FormatterVariant]
    """
    List of formatters to apply to messages before output.
    """
    var filters:List[FilterVariant]
    """
    List of filters that determine which messages should be processed.
    """
    var outputs:List[OutputerVariant]
    """
    List of outputers that receive formatted messages for final delivery.
    """

    @staticmethod
    fn get_default_logger(name: String, level: String='INFO') -> Logger:
        """
        Create a logger with default configuration.
        
        Args:
            name: Identifier for this logger
            level: Log level name (default: 'INFO')
            
        Returns:
            Logger: A configured logger with default components
            
        This creates a logger with the standard filter, formatter and outputer.
        """
        try:
            logger = Logger(name, LOG_LEVELS[level])
            logger.add_formatter(DefaultLoggerFormatter(logger.name, logger.level))
            logger.add_filter(DefaultLoggerFilter(logger.name, logger.level))
            logger.add_output(DefaultLoggerOutputer(logger.name, logger.level))
            return logger^
        except:
            print('Failed to create default logger for ' + name)
            return Logger(name, 0)


    fn __init__(out self, name: String, level: Int=0):
        """
        Initialize a new Logger instance.
        
        Args:
            name: Identifier for this logger
            level: Numeric level threshold (default: 0, which is TRACE)
            
        This creates a logger with no filters, formatters, or outputers.
        You'll need to add those separately.
        """
        self.name = name
        self.level = level
        debug_assert(self.level in LOG_LEVELS_NUMERIC, 'Invalid log level: ' + String(self.level))
        self.formatters = List[FormatterVariant]()
        self.filters = List[FilterVariant]()
        self.outputs = List[OutputerVariant]()


    fn _apply_formatter(self, formatter_var: FormatterVariant, message: String) -> String:
        """
        Apply a formatter to a message.
        
        Args:
            formatter_var: The formatter to apply
            message: The message to format
            
        Returns:
            String: The formatted message
        """
        @parameter
        for i in range(len(VariadicList(FormatterVariant.Ts))):
            alias T = FormatterVariant.Ts[i]
            if formatter_var.isa[T]():
                return formatter_var[T].format(message)
        return message

    fn _apply_filter(self, filter_var: FilterVariant, level: Int, message: String) -> Bool:
        """
        Apply a filter to a message.
        
        Args:
            filter_var: The filter to apply
            level: Numeric level of the message
            message: Content of the message
            
        Returns:
            Bool: True if the message passes the filter, False otherwise
        """
        @parameter
        for i in range(len(VariadicList(FilterVariant.Ts))):
            alias T = FilterVariant.Ts[i]
            if filter_var.isa[T]():
                return filter_var[T].filter(level, message)
        return True  # Default pass if filter type not recognized

    fn _apply_output(self, output_var: OutputerVariant, message: String):
        """
        Send a message to an output.
        
        Args:
            output_var: The outputer to use
            message: The formatted message to output
        """
        @parameter
        for i in range(len(VariadicList(OutputerVariant.Ts))):
            alias T = OutputerVariant.Ts[i]
            if output_var.isa[T]():
                output_var[T].output(message)
        return

    fn info(self, message:String):
        """
        Log a message at INFO level (20).
        
        Args:
            message: The message to log
            
        INFO is used for general runtime information about normal operation.
        """
        for filterer in self.filters:
            if not self._apply_filter(filterer[], self.level, message):
                return

        # for formatter in self.formatters:
        #     message = formatter.format(message)



    fn debug(self, message:String):
        """
        Log a message at DEBUG level (10).
        
        Args:
            message: The message to log
            
        DEBUG is used for detailed information useful during development.
        """
        print(self.name + ': ' + message)

    fn critical(self, message:String):
        """
        Log a message at CRITICAL level (50).
        
        Args:
            message: The message to log
            
        CRITICAL is used for severe errors that may lead to program termination.
        """
        print(self.name + ': ' + message)

    fn error(self, message:String):
        """
        Log a message at ERROR level (40).
        
        Args:
            message: The message to log
            
        ERROR is used for serious issues that prevent operations from succeeding.
        """
        print(self.name + ': ' + message)

    fn warning(self, message:String):
        """
        Log a message at WARNING level (30).
        
        Args:
            message: The message to log
            
        WARNING is used for potential issues that don't prevent normal operation.
        """
        print(self.name + ': ' + message)

    fn trace(self, message:String):
        """
        Log a message at TRACE level (0).
        
        Args:
            message: The message to log
            
        TRACE is the most verbose level, for fine-grained debugging information.
        """
        print(self.name + ': ' + message)

    fn add_formatter(mut self, owned formatter:FormatterVariant):
        """
        Add a formatter to the logger.
        
        Args:
            formatter: The formatter to add
            
        Formatters transform messages before they are output.
        They are applied in the order they are added.
        """
        self.formatters.append(formatter)

    fn add_filter(mut self, owned filter: FilterVariant):
        """
        Add a filter to the logger.
        
        Args:
            filter: The filter to add
            
        Filters determine whether messages should be processed or dropped.
        If any filter rejects a message, it will not be processed further.
        """
        self.filters.append(filter)

    fn add_output(mut self, owned output:OutputerVariant):
        """
        Add an outputer to the logger.
        
        Args:
            output: The outputer to add
            
        Outputers handle the final delivery of formatted messages.
        All configured outputers receive the same formatted messages.
        """
        self.outputs.append(output)
