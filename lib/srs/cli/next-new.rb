module SRS
	class CLI
		class NextNew
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				new_schedules = Dir["schedule/pending/*"].sort_by{ |f| File.ctime(f) }
				if not new_schedules.empty?
					puts File.basename new_schedules.first
				end

				return 0
			end

			def help()
				puts <<-EOF
srs next-new

Prints out the id of the next untested schedule.  Prints nothing if there are no
pending schedules.
					EOF
			end
		end
	end
end

