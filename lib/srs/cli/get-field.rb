module SRS
	class CLI
		class GetField
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				field = arguments.shift
				id = arguments.shift

				if field == nil or id == nil then
					return 4
				end

				is_schedule = (id =~ /\d{14}\.\d{3}/)

				filename = ""
				if is_schedule then
					filename = "schedule/#{id}"
					filename = "schedule/pending/#{id}" if not File.exists?(filename)
				else
					filename = "exercises/#{id}"
				end

				if not File.exists?(filename) then
					puts "No content with that ID exists"
					return 4
				end

				File.open(filename, "r") do |file|
					while( line = file.gets() ) do
						if line.strip.empty? then
							break
						end

						key, *val = line.split(':').map{|e| e.strip}
						if key.casecmp(field) == 0 then
							puts val.join(':')
							return 0
						end
					end
				end

				puts "Content #{id} does not contain field \"#{field}\"."
				return 4
			end

			def help()
				puts <<-EOF
srs get-field <field-name> <content-id>

Returns the value of the field <field-name> from content <content-id>
					EOF
			end
		end
	end
end

