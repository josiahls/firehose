# Native Mojo Modules
# Third Party Mojo Modules
# First Party Modules


trait LoggerFilter(CollectionElement):
    fn filter(self, level: Int, message: String) -> Bool: ...
