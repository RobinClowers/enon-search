require 'logger'

AppLogger = Logger.new(STDOUT)
AppLogger.level = ENV.fetch('LOG_LEVEL', 'info')
