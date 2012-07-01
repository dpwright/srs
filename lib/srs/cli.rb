require 'srs/cli/init'
require 'srs/cli/help'

module SRS
	class CLI
		class << self
			COMMANDS = { "init"   => :Init,
						 "help"   => :Help }.freeze

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

