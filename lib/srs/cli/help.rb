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
				puts "Usage: srs <command> [args]"
				puts
				puts "Available commands are:"
				puts "    init          Initialise an SRS workspace"
				puts "    insert-into   Insert data into the workspace"
				puts "    schedule      Schedule an exercise"
				puts "    do-exercise   Perform a rep on an exercise"
				puts "    reschedule    Update an exercise schedule based on score"
				puts "    queue         Queue due exercises"
				puts "    next-due      Retrieve the next due exercise from the queue"
				puts "    next-new      Retrieve the next available untested exercise"
				puts "    get-field     Retrieve a field by name from a schedule or exercise"
				puts "    cat           Output data contained within the workspace"
				puts
				puts "See 'srs help <command>' for more information on a specific command."
			end
		end
	end
end


