require 'srs/cli'

module SRS
	class CLI
		class Help
			def run!(arguments)
				if arguments.empty?
					summary
				else
					command = SRS::CLI::cmd_to_symbol(arguments.first)
					if command
						SRS::CLI.const_get(command).new.help()
					else
						summary
					end
				end
				return 0
			end

			def help()
			end

			def summary()
				puts "    init"
				puts "    add-data"
				puts "    cat"
				puts "    help"
			end
		end
	end
end


