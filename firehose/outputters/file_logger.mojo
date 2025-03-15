# Native Mojo Modules
from collections.list import List
# Third Party Mojo Modules
# First Party Modules
from firehose.outputters.common import LoggerOutputer
from firehose.common import Record


@value
struct FileLoggerOutputer(LoggerOutputer):
    """
    FileLoggerOutputer: Logs messages to a file.
    
    This outputter writes log messages to a specified file, appending them to the end of the file.
    
    """
    var file_path: String
    var file_mode: String
    var file_handle: FileHandle

    fn __init__(out self, file_path: String, file_mode: String):
        self.file_path = file_path
        self.file_mode = file_mode
        try:
            self.file_handle = FileHandle(file_path, file_mode)
        except:
            print("Failed to open file: " + file_path)
            self.file_handle = FileHandle()

    fn __copyinit__(out self, other: FileLoggerOutputer):
        self.file_path = other.file_path
        self.file_mode = other.file_mode
        try:
            self.file_handle = FileHandle(other.file_path, other.file_mode)
        except:
            print("Failed to open file: " + other.file_path)
            self.file_handle = FileHandle()

    fn output(mut self, record: Record):
        self.file_handle.write(record.message)
        self.file_handle.write("\n")

