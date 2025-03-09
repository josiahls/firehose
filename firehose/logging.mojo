# Native Mojo Modules
from collections.dict import Dict
from utils import Variant
# Third Party Mojo Modules
# First Party Modules
from firehose import FormatterVariant, FilterVariant, OutputerVariant, LOG_LEVELS, LOG_LEVELS_NUMERIC


@value
struct Logger:
    var name:String
    var level:Int
    var formatters:List[FormatterVariant]
    var filters:List[FilterVariant]
    var outputs:List[OutputerVariant]

    @staticmethod
    fn get_default_logger(name: String, level: String='INFO') -> Logger:
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
        self.name = name
        self.level = level
        debug_assert(self.level in LOG_LEVELS_NUMERIC, 'Invalid log level: ' + String(self.level))
        self.formatters = List[FormatterVariant]()
        self.filters = List[FilterVariant]()
        self.outputs = List[OutputerVariant]()


    fn _apply_formatter(self, formatter_var: FormatterVariant, message: String) -> String:
        @parameter
        for i in range(len(VariadicList(FormatterVariant.Ts))):
            alias T = FormatterVariant.Ts[i]
            if formatter_var.isa[T]():
                return formatter_var[T].format(message)
        return message

    fn _apply_filter(self, filter_var: FilterVariant, level: Int, message: String) -> Bool:
        @parameter
        for i in range(len(VariadicList(FilterVariant.Ts))):
            alias T = FilterVariant.Ts[i]
            if filter_var.isa[T]():
                return filter_var[T].filter(level, message)
        return True  # Default pass if filter type not recognized

    fn _apply_output(self, output_var: OutputerVariant, message: String):
        @parameter
        for i in range(len(VariadicList(OutputerVariant.Ts))):
            alias T = OutputerVariant.Ts[i]
            if output_var.isa[T]():
                output_var[T].output(message)
        return

    fn info(self, message:String):
        for filterer in self.filters:
            if not self._apply_filter(filterer[], self.level, message):
                return

        # for formatter in self.formatters:
        #     message = formatter.format(message)



    fn debug(self, message:String):
        print(self.name + ': ' + message)

    fn critical(self, message:String):
        print(self.name + ': ' + message)

    fn error(self, message:String):
        print(self.name + ': ' + message)

    fn warning(self, message:String):
        print(self.name + ': ' + message)

    fn trace(self, message:String):
        print(self.name + ': ' + message)

    fn add_formatter(mut self, owned formatter:FormatterVariant):
        self.formatters.append(formatter)

    fn add_filter(mut self, owned filter: FilterVariant):
        self.filters.append(filter)

    fn add_output(mut self, owned output:OutputerVariant):
        self.outputs.append(output)
