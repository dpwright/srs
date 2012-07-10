module SRS
	class CLI
		class Cat
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				id = arguments.shift

				if File.exists?(id) then
					contents = File.open(id, "r"){ |file| file.read }
					puts contents

					return 0
				end

				puts "No content with that ID exists"
				return 4
			end

			def help()
				puts <<-EOF
srs cat <id>

Outputs the content matching <id>
					EOF
			end
		end
	end
end

