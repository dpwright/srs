require 'fileutils'

module SRS
	class CLI
		class InsertInto
			VALID_SECTIONS = ["data", "exercises"].freeze
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				section = arguments.shift()
				if section == nil or !VALID_SECTIONS.include?(section) then
					help()
					return 4
				end

				id = arguments.shift()
				if id == nil then
					help()
					return 4
				end

				data = STDIN.read()
				datafile = "#{section}/#{id}"

				if File.exists?(datafile) then
					puts "Content #{id} already exists in #{section}."
					return 5
				end

				FileUtils::mkdir_p("#{section}")
				File.open(datafile, 'w') {|f| f.write(data)}

				puts datafile

				return 0
			end

			def help()
				puts <<-EOF
srs insert-into <section> <id> [options]

Reads the contents from stdin and inserts it into the appropriate section in the
workspace.  <section> can be one of "data" or "exercise".  <id> is the id you
want to give to the content, local to that section.  Returns the absolute id
used to access that content.
				EOF
			end
		end
	end
end

