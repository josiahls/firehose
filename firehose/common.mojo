# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules
from builtin._location import __call_location, _SourceLocation


@fieldwise_init
struct Record(Copyable & Movable):
    """
    Record: Represents a log message and its associated metadata.

    A Record maintains both the original message and its potentially formatted version,
    along with level information for both the logger and the specific message.
    This allows the logging system to track how a message is transformed through
    the processing pipeline while preserving the original content.
    """

    var original_message: String
    """
    The unmodified message as it was originally passed to the logger.
    This is preserved even if formatters modify the message content.
    """
    var message: String
    """
    The current version of the message, which may have been modified by formatters.
    This is the version that will be sent to outputters.
    """
    var logger_level: Int
    """
    The configured level threshold of the logger that created this record.
    Used by filters to determine if the message meets the logger's minimum level.
    """
    var message_level: Int
    """
    The severity level at which this message was logged (e.g., INFO=20, DEBUG=10).
    This indicates which logging method was called (info(), debug(), etc.).
    """
    var logger_name: String
    """
    The name of the logger that created this record.
    """
    var source_location: _SourceLocation
    """
    The source location of the log message.
    """
