# Native Mojo Modules
from collections.dict import Dict
from utils import Variant
from memory import ArcPointer, UnsafePointer
from builtin._location import __call_location
from sys.ffi import _Global
import os

# Third Party Mojo Modules
# First Party Modules
from firehose import (
    FormatterVariant,
    FilterVariant,
    OutputerVariant,
    LOG_LEVELS,
    LOG_LEVELS_NUMERIC,
    Record,
)


@fieldwise_init
struct _GlobalLoggerSettings(Copyable, Movable):
    var default_logger_level: Int
    var initialized: Bool

    fn __init__(out self):
        self.default_logger_level = LOG_LEVELS.get("INFO", 20)
        self.initialized = True

    fn set_initialized(mut self, initialized: Bool):
        self.initialized = initialized


fn _init_global_logger_settings() -> _GlobalLoggerSettings:
    return _GlobalLoggerSettings()


alias _LOGGER_SETTINGS_GLOBAL = _Global[
    "LoggerSettings", _GlobalLoggerSettings, _init_global_logger_settings
]


@always_inline
fn get_global_logger_settings() -> UnsafePointer[_GlobalLoggerSettings]:
    return _LOGGER_SETTINGS_GLOBAL.get_or_create_ptr()


fn disable_global_logger_settings():
    get_global_logger_settings()[].set_initialized(False)


fn set_global_logger_settings(level: Int):
    var settings = get_global_logger_settings()
    settings[].set_initialized(True)
    settings[].default_logger_level = level


@fieldwise_init
struct Logger(Copyable, Movable):
    """
    Logger: The main entry point for the Firehose logging system.

    The Logger class provides methods for logging messages at different
    severity levels and manages the processing pipeline through filters,
    formatters, and outputters.

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

    alias FIREHOSE_LEVEL_ENV_VAR = "FIREHOSE_LEVEL"

    var name: String
    """
    Name of the logger instance, used for identification in log messages.
    """
    var level: Int
    """
    The base logging level for this logger. Messages with a level below
    this value will be filtered out.
    """
    var formatters: List[ArcPointer[FormatterVariant]]
    """
    List of formatters to apply to messages before output.
    Each formatter is stored as an ArcPointer to maintain shared ownership.
    """
    var filterers: List[ArcPointer[FilterVariant]]
    """
    List of filterers that determine which messages should be processed.
    Each filterer is stored as an ArcPointer to maintain shared ownership.
    """
    var outputters: List[ArcPointer[OutputerVariant]]
    """
    List of outputters that receive formatted messages for final delivery.
    Each outputter is stored as an ArcPointer to maintain shared ownership.
    """

    @staticmethod
    fn get_default_logger(name: String) -> Logger:
        """
        Create a logger with default configuration.

        Args:
            name: Identifier for this logger.

        Returns:
            Logger: A configured logger with default components

        This creates a logger with the standard filter, formatter and outputter.
        """
        var level = get_global_logger_settings()[].default_logger_level

        var logger = Logger(name, level)
        # Create components with ArcPointers
        var formatter = ArcPointer[FormatterVariant](DefaultLoggerFormatter())
        var filter = ArcPointer[FilterVariant](DefaultLoggerFilter())
        var output = ArcPointer[OutputerVariant](DefaultLoggerOutputer())

        logger.add_formatter(formatter^)
        logger.add_filter(filter^)
        logger.add_outputter(output^)
        return logger^

    fn __init__(out self, name: String, level: Int = 0):
        """
        Initialize a new Logger instance.

        Args:
            name: Identifier for this logger
            level: Numeric level threshold (default: 0, which is TRACE).

        This creates a logger with no filters, formatters, or outputters.
        You'll need to add those separately.
        """
        self.name = name
        self.level = level
        debug_assert(
            self.level in LOG_LEVELS_NUMERIC,
            "Invalid log level: " + String(self.level),
        )
        self.formatters = List[ArcPointer[FormatterVariant]]()
        self.filterers = List[ArcPointer[FilterVariant]]()
        self.outputters = List[ArcPointer[OutputerVariant]]()

    fn __init__(out self, name: String, level: String = "INFO"):
        """
        Initialize a new Logger instance.
        """
        self.name = name
        self.level = LOG_LEVELS.get(level, -1)  # Force a debug assert
        debug_assert(
            self.level in LOG_LEVELS_NUMERIC,
            "Invalid log level: " + String(self.level),
        )
        self.formatters = List[ArcPointer[FormatterVariant]]()
        self.filterers = List[ArcPointer[FilterVariant]]()
        self.outputters = List[ArcPointer[OutputerVariant]]()

    fn get_level(self) -> Int:
        env_level = os.getenv(self.FIREHOSE_LEVEL_ENV_VAR)
        if env_level != "":
            return LOG_LEVELS.get(env_level, -1)
        return self.level

    fn add_formatter(mut self, var formatter: FormatterVariant):
        """
        Add a formatter to the logger by taking ownership.

        Args:
            formatter: The formatter to add

        WARNING: This method creates a copy of the formatter. If you need to
        access the formatter after adding it to the logger, use add_formatter
        with an ArcPointer instead.
        """
        print(
            "Warning: Creating copy of formatter. If you need to access this"
            " formatter "
            + "after adding it to the logger, use add_formatter with an"
            " ArcPointer instead."
        )
        self.formatters.append(ArcPointer[FormatterVariant](formatter^))

    fn add_formatter_copy(mut self, var  formatter: FormatterVariant):
        """
        Add a formatter to the logger by taking ownership. This will make a copy of the formatter.
        """
        self.formatters.append(ArcPointer[FormatterVariant](formatter^))

    fn add_formatter(mut self, var formatter: ArcPointer[FormatterVariant]):
        """
        Add a formatter to the logger using an ArcPointer.

        Args:
            formatter: ArcPointer to the formatter to add

        This method maintains shared ownership of the formatter, allowing
        you to still access it after adding it to the logger.
        """
        self.formatters.append(formatter^)

    fn add_filter(mut self, var filter: FilterVariant):
        """
        Add a filter to the logger by taking ownership.

        Args:
            filter: The filter to add

        WARNING: This method creates a copy of the filter. If you need to
        access the filter after adding it to the logger, use add_filter
        with an ArcPointer instead.
        """
        print(
            "Warning: Creating copy of filter. If you need to access this"
            " filter "
            + "after adding it to the logger, use add_filter with an ArcPointer"
            " instead."
        )
        self.filterers.append(ArcPointer[FilterVariant](filter^))

    fn add_filter_copy(mut self, var  filter: FilterVariant):
        """
        Add a filter to the logger by taking ownership. This will make a copy of the filter.
        """
        self.filterers.append(ArcPointer[FilterVariant](filter^))

    fn add_filter(mut self, var filter: ArcPointer[FilterVariant]):
        """
        Add a filter to the logger using an ArcPointer.

        Args:
            filter: ArcPointer to the filter to add

        This method maintains shared ownership of the filter, allowing
        you to still access it after adding it to the logger.
        """
        self.filterers.append(filter^)

    fn add_outputter(mut self, var  output: OutputerVariant):
        """
        Add an outputter to the logger by taking ownership.

        Args:
            output: The outputter to add

        WARNING: This method creates a copy of the outputter. If you need to
        access the outputter after adding it to the logger, use add_outputter
        with an ArcPointer instead.
        """
        print(
            "Warning: Creating copy of outputter. If you need to access this"
            " outputter "
            + "after adding it to the logger, use add_outputter with an"
            " ArcPointer instead."
        )
        self.outputters.append(ArcPointer[OutputerVariant](output^))

    fn add_outputter_copy(mut self, var  output: OutputerVariant):
        """
        Add an outputter to the logger by taking ownership. This will make a copy of the outputter.
        """
        self.outputters.append(ArcPointer[OutputerVariant](output^))

    fn add_outputter(mut self, var  output: ArcPointer[OutputerVariant]):
        """
        Add an outputter to the logger using an ArcPointer.

        Args:
            output: ArcPointer to the outputter to add.

        This method maintains shared ownership of the outputter, allowing
        you to still access it after adding it to the logger.
        """
        self.outputters.append(output^)

    fn _apply_formatter(
        self, formatter_ptr: ArcPointer[FormatterVariant], record: Record
    ) -> Record:
        @parameter
        for i in range(len(VariadicList(FormatterVariant.Ts))):
            alias T = FormatterVariant.Ts[i]
            if formatter_ptr[].isa[T]():
                return formatter_ptr[][T].format(record)
        return record

    fn _apply_filter(
        self, filter_ptr: ArcPointer[FilterVariant], record: Record
    ) -> Bool:
        @parameter
        for i in range(len(VariadicList(FilterVariant.Ts))):
            alias T = FilterVariant.Ts[i]
            if filter_ptr[].isa[T]():
                return filter_ptr[][T].filter(record)
        return True

    fn _apply_output(
        self, mut output_ptr: ArcPointer[OutputerVariant], record: Record
    ):
        @parameter
        for i in range(len(VariadicList(OutputerVariant.Ts))):
            alias T = OutputerVariant.Ts[i]
            if output_ptr[].isa[T]():
                output_ptr[][T].output(record)

    fn run_pipeline(mut self, mut record: Record) -> Bool:
        """Run the pipeline of filters, formatters, and outputters."""
        var current_record = record

        # Apply filters
        for i in range(len(self.filterers)):
            var filter = self.filterers[i]
            if not self._apply_filter(filter, current_record):
                return False

        # Apply formatters
        for i in range(len(self.formatters)):
            var formatter = self.formatters[i]
            current_record = self._apply_formatter(formatter, current_record)

        # Apply outputs
        var final_record = current_record
        for i in range(len(self.outputters)):
            var outputter = self.outputters[i]
            self._apply_output(outputter, final_record)

        return True

    fn make_record(mut self, message: String, log_level: Int) -> Record:
        """
        Make a record for a message.
        """
        return Record(
            message,
            message,
            self.level,
            log_level,
            self.name,
            __call_location[inline_count=0](),
        )

    @always_inline("nodebug")
    fn trace(mut self, message: String):
        var record = Record(
            message,
            message,
            self.get_level(),
            LOG_LEVELS.get("TRACE", 0),
            self.name,
            __call_location[inline_count=1](),
        )
        _ = self.run_pipeline(record)

    @always_inline("nodebug")
    fn debug(mut self, message: String):
        var record = Record(
            message,
            message,
            self.get_level(),
            LOG_LEVELS.get("DEBUG", 0),
            self.name,
            __call_location[inline_count=1](),
        )
        _ = self.run_pipeline(record)

    @always_inline("nodebug")
    fn info(mut self, message: String):
        var record = Record(
            message,
            message,
            self.get_level(),
            LOG_LEVELS.get("INFO", 0),
            self.name,
            __call_location[inline_count=1](),
        )
        _ = self.run_pipeline(record)

    @always_inline("nodebug")
    fn warning(mut self, message: String):
        var record = Record(
            message,
            message,
            self.get_level(),
            LOG_LEVELS.get("WARNING", 0),
            self.name,
            __call_location[inline_count=1](),
        )
        _ = self.run_pipeline(record)

    @always_inline("nodebug")
    fn error(mut self, message: String):
        var record = Record(
            message,
            message,
            self.get_level(),
            LOG_LEVELS.get("ERROR", 0),
            self.name,
            __call_location[inline_count=1](),
        )
        _ = self.run_pipeline(record)

    @always_inline("nodebug")
    fn critical(mut self, message: String):
        var record = Record(
            message,
            message,
            self.get_level(),
            LOG_LEVELS.get("CRITICAL", 0),
            self.name,
            __call_location[inline_count=1](),
        )
        _ = self.run_pipeline(record)
