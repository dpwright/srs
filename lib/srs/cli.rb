require 'srs/cli/init'
require 'srs/cli/help'
require 'srs/cli/insert-data'
require 'srs/cli/insert-exercise'
require 'srs/cli/cat'

module SRS
	class CLI
		class << self
			COMMANDS = { "init"            => :Init,
			             "insert-data"     => :InsertData,
			             "insert-exercise" => :InsertExercise,
			             "cat"             => :Cat,
			             "help"            => :Help }.freeze

			def cmd_to_symbol(command)
				return COMMANDS[command]
			end

			def run!(*arguments)
				command = cmd_to_symbol(arguments.shift)
				if command
					return SRS::CLI.const_get(command).new.run!(arguments)
				else
					return SRS::CLI::Help.new.run!([])
				end
			end
		end
	end
end

