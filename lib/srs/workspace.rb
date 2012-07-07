require 'fileutils'

module SRS
	class Workspace
		class AlreadyInitialisedError < StandardError
		end
		class FolderNotEmptyError < StandardError
		end

		attr_reader :root, :dotsrs

		def initialize(dirname=".")
			if not SRS::Workspace.initialised?(dirname) then return nil end
			@root = dirname
			@dotsrs = File.join(dirname,'.srs')
			self
		end

		def self.create(dirname, force=false)
			dotsrs_dir = File.join(dirname,'.srs/')

			if( SRS::Workspace.initialised?(dirname) ) then
				raise AlreadyInitialisedError
				return nil
			end

			FileUtils.mkdir_p(dirname)

			if( !force ) then
				if( Dir.entries(dirname).length > 2 ) then
					raise FolderNotEmptyError
					return nil
				end
			end

			Dir.mkdir(dotsrs_dir)
			Dir.mkdir(File.join(dirname, "data"))

			return SRS::Workspace.new(dirname)
		end

		def self.initialised?(dirname=".")
			Dir.exists?(File.join(dirname,'.srs/'))
		end
	end
end
