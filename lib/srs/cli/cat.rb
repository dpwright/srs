module SRS
	class CLI
		class Cat
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				sha1 = arguments.shift
				sha1_start = sha1[0..1]
				sha1_rest = sha1[2..-1]
				datafile = "data/#{sha1_start}/#{sha1_rest}"

				if not File.exists?(datafile) then
					puts "No content with that ID exists"
					return 4
				end

				contents = File.open(datafile, "r"){ |file| file.read }
				puts contents

				return 0
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



