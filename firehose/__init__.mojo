# Native Mojo Modules
from utils import Variant
from collections.dict import Dict
from collections.list import List
# Third Party Mojo Modules
# First Party Modules

# Import the default implementations
from firehose.filterers.default import DefaultLoggerFilter
from firehose.formatters.default import DefaultLoggerFormatter
from firehose.outputers.default import DefaultLoggerOutputer
from firehose.outputers.test import TestLoggerOutputer

# Define the variants
alias FilterVariant = Variant[DefaultLoggerFilter]
alias FormatterVariant = Variant[DefaultLoggerFormatter]
alias OutputerVariant = Variant[DefaultLoggerOutputer, TestLoggerOutputer]


# Initialize the log levels
fn _init_log_levels() -> Dict[String, Int]:
    d = Dict[String, Int]()
    d['TRACE']    = 0   # Typically inner loop logging statements (e.g. "Loop iter 1000")
    d['DEBUG']    = 10  # Noisy logging statements for debugging (e.g. "Item dump: 1,2,3...")
    d['INFO']     = 20  # Regular runtime information (e.g. "Executing phase 1 of 3")
    d['WARNING']  = 30  # Potential issues (e.g. "Skipping item 1000 due to missing data")
    d['ERROR']    = 40  # Serious issues (e.g. "Failed to parse item 1000")
    d['CRITICAL'] = 50  # Critical issues (e.g. "Program is unstable, shutting down")
    return d


fn _init_log_levels_numeric() -> List[Int]:
    numeric_levels = List[Int]()
    for level in _init_log_levels().values():
        numeric_levels.append(level[])
    return numeric_levels


fn _init_log_levels_keys() -> List[String]:
    keys = List[String]()
    for key in _init_log_levels().keys():
        keys.append(key[])
    return keys


alias LOG_LEVELS = _init_log_levels()
alias LOG_LEVELS_NUMERIC = _init_log_levels_numeric()
alias LOG_LEVELS_KEYS = _init_log_levels_keys()