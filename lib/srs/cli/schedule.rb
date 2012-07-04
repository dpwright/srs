require 'fileutils'

module SRS
	class CLI
		class Schedule
			def initialize
				@options = {}
				@opts = OptionParser.new do |o|
					o.banner = <<-EOF.gsub /^\s+/, ""
						srs schedule [options] <exercise>

						Schedules an exercise.
						EOF

					o.on('-s', '--scheduler SCHEDULER_NAME', 'Specifies which scheduler to use') do |s|
						@options[:scheduler] = s
					end
				end
			end

			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				begin
					@opts.parse!(arguments)
					@options[:exercise] = arguments.shift()
				rescue OptionParser::InvalidOption => e
					@options[:invalid_argument] = e.message
				end

				if @options[:exercise] == nil then
					help()
					return 4
				end

				if @options[:scheduler] == nil then
					puts "No scheduler specified."
					return 5
				end

				t = Time.now
				filename = "schedule/pending/#{t.strftime("%Y%m%d%H%M%S.%L")}"

				if File.exists?(filename) then
					puts "Cannot schedule two items within a millisecond.  Try again."
					return 6
				end

				FileUtils::mkdir_p("schedule/pending")
				File.open(filename, 'w') do |f|
					f.puts "Exercise: #{@options[:exercise]}"
					f.puts "Scheduler: #{@options[:scheduler]}"
				end

				puts filename

				return 0
			end

			def help()
				puts @opts
			end
		end
	end
end

