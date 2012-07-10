require 'fileutils'

module SRS
	class CLI
		class InsertInto
			VALID_SECTIONS = ["data", "exercises"].freeze
			def initialize
				@options = {}
				@opts = OptionParser.new do |o|
					o.on('-f', '--force', 'Overwrite any existing content with the same id') do
						@options[:force] = true
					end
				end
			end

			def run!(arguments)
				begin
					@opts.parse!(arguments)
					@options[:section] = arguments.shift
					@options[:id] = arguments.shift
				rescue OptionParser::InvalidOption => e
					@options[:invalid_argument] = e.message
				end

				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				if @options[:section] == nil or !VALID_SECTIONS.include?(@options[:section]) then
					help()
					return 4
				end

				if @options[:id] == nil then
					help()
					return 4
				end

				data = STDIN.read()
				datafile = "#{@options[:section]}/#{@options[:id]}"

				if File.exists?(datafile) and  not @options[:force] then
					puts "Content #{@options[:id]} already exists in #{@options[:section]}."
					puts "Use --force to overwrite it."
					return 5
				end

				FileUtils::mkdir_p("#{@options[:section]}")
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
				puts @opts
			end
		end
	end
end

