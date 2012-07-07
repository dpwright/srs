module SRS
	class CLI
		class NextDue
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				ws = SRS::Workspace.new

				schedule = nil
				if File.exists? "#{ws.dotsrs}/QUEUED" then
					File.open("#{ws.dotsrs}/QUEUED", "r") do |queued_file|
						schedule = queued_file.gets
					end
				end

				if schedule == nil then
					if File.exists? "#{ws.dotsrs}/REPEAT" then
						File.open("#{ws.dotsrs}/REPEAT", "r") do |repeat_file|
							schedule = repeat_file.gets
						end
					end
				end

				if not schedule == nil then
					puts File.basename schedule
				end

				return 0
			end

			def help()
				puts <<-EOF
srs next-due

Prints out the id of the next due schedule.  Prints nothing if nothing is due.
					EOF
			end
		end
	end
end

