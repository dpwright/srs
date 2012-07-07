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
				puts "    insert-into"
				puts "    schedule"
				puts "    do-exercise"
				puts "    reschedule"
				puts "    queue"
				puts "    next-due"
				puts "    next-new"
				puts "    get-field"
				puts "    cat"
				puts "    help"
			end
		end
	end
end


