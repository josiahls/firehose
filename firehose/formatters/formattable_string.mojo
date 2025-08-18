# Native Mojo Modules
from collections.dict import Dict

# Third Party Mojo Modules
# First Party Modules


@fieldwise_init
struct FormattableString(Copyable & Movable):
    """
    FormattableString: A string that extracts metadata for a formatter to use
    when formatting a message.

    Example:
    ```
    var fmt = FormattableString("%(logger_name)s - %(message_level)s: %(original_message)s")
    ```
    """

    var raw_format: String
    """The original format string with named placeholders."""

    var field_names: List[String]
    """List of field names extracted from the format string."""

    fn __init__(out self, format_string: String):
        """
        Initialize a new FormattableString.

        Args:
            format_string: The format string with named placeholders.
                         Format: "%(field_name)s" or "{field_name}".
        """
        self.raw_format = format_string
        self.field_names = List[String]()

        for field_name in self.raw_format.split("%("):
            if ")s" in field_name:
                for middle in field_name.split(")s"):
                    self.field_names.append(String(middle))
                    break  # Only keep the first section
