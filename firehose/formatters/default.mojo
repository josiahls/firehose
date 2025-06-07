# Native Mojo Modules
from memory import ArcPointer
from pathlib import Path

# Third Party Mojo Modules
# First Party Modules
from firehose.formatters.common import LoggerFormatter
from firehose.common import Record
from firehose.formatters.formattable_string import FormattableString
from firehose import LOG_LEVEL_NAMES_FROM_NUMERIC


@value
struct DefaultLoggerFormatter(LoggerFormatter):
    """
    DefaultLoggerFormatter: Standard pass-through message formatter.

    This is the default formatter implementation that passes log messages
    through unchanged. It serves as a minimal implementation of the
    LoggerFormatter trait and a starting point for custom formatters.

    Example:
    ```
    var formatter = DefaultLoggerFormatter("basic_formatter", LOG_LEVELS['INFO'])

    # Message passes through unchanged
    formatter.format("Hello, world!") # Returns "Hello, world!"
    ```

    In real applications, you'll typically want to create custom formatters
    that add context like timestamps, source information, or log levels.
    """

    var format_string: FormattableString
    """
    The format string to use for the log message.
    """

    alias SUPPORTED_STRING_FIELDS: List[String] = List(
        String("file"),
        String("file_name"),
        String("line"),
        String("column"),
        String("logger_name"),
        String("message_level"),
        String("message_level_name"),
        String("message_level_name_short"),
        String("original_message"),
    )

    # TODO(josiahls): Mojo doesn't have time or datetime utilities, so we can't use the default format string.
    # fn __init__(out self, format_string: String='%(asctime)s - %(name)s - %(levelname)s - %(message)s'):
    fn __init__(
        out self,
        format_string: String = "%(file_name)s:%(line)s - %(message_level_name)s: %(original_message)s",
    ):
        """
        Initialize a new DefaultLoggerFormatter.

        Args:
            format_string: The format string to use for the log message.

        Example:
        ```
        var formatter = DefaultLoggerFormatter()
        ```
        """
        self.format_string = FormattableString(format_string)
        for field_name in self.format_string.field_names:
            if field_name not in Self.SUPPORTED_STRING_FIELDS:
                print("Warning: Unsupported field name: " + field_name)

    fn format(self, record: Record) -> Record:
        """
        Format a log message (pass-through implementation).

        Args:
            record: The record to format.

        Returns:
            Record: The formatted record (unchanged in the default implementation)

        The DefaultLoggerFormatter simply returns the record unchanged.
        Custom formatters would override this to add timestamps, log levels,
        source information, etc.
        """
        var formatted_message = self.format_string.raw_format

        for field_name in self.format_string.field_names:
            record_field_value = String()

            if field_name == "logger_name":
                record_field_value = record.logger_name
            elif field_name == "message_level":
                record_field_value = String(record.message_level)
            elif field_name == "message_level_name":
                record_field_value = String(
                    LOG_LEVEL_NAMES_FROM_NUMERIC.get(
                        record.message_level, "UNKNOWN"
                    )
                )
            elif field_name == "message_level_name_short":
                record_field_value = String(
                    LOG_LEVEL_NAMES_FROM_NUMERIC.get(
                        record.message_level, "UNKNOWN"
                    )[0]
                )
            elif field_name == "original_message":
                record_field_value = record.original_message
            elif field_name == "column":
                record_field_value = String(record.source_location.col)
            elif field_name == "file":
                record_field_value = String(record.source_location.file_name)
            elif field_name == "file_name":
                try:
                    splits = record.source_location.file_name.split("/")
                    record_field_value = String(splits[-1])
                except:
                    record_field_value = String()
            elif field_name == "line":
                record_field_value = String(record.source_location.line)

            formatted_message = formatted_message.replace(
                "%(" + field_name + ")s", record_field_value
            )

        return Record(
            original_message=record.original_message,
            message=formatted_message,
            logger_name=record.logger_name,
            logger_level=record.logger_level,
            message_level=record.message_level,
            source_location=record.source_location,
        )
