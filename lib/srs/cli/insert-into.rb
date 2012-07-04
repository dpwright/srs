require 'fileutils'
require 'digest/sha1'

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

				data = STDIN.read()
				sha1 = Digest::SHA1.hexdigest data
				sha1_start = sha1[0..1]
				sha1_rest = sha1[2..-1]
				datafile = "#{section}/#{sha1_start}/#{sha1_rest}"

				if not File.exists?(datafile) then
					FileUtils::mkdir_p("#{section}/#{sha1_start}")
					File.open(datafile, 'w') {|f| f.write(data)}
				end

				puts sha1

				return 0
			end

			def help()
				puts <<-EOF
srs insert-into <section>

Reads the contents from stdin and inserts it into the appropriate section in the
workspace.  <section> can be one of "data", "exercise", or "schedule".  Returns
the id used to access that exercise.
				EOF
			end
		end
	end
end

