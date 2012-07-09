require File.expand_path("../lib/srs/version", __FILE__)

Gem::Specification.new do |s|
	s.name         = 'srs'
	s.version      = SRS::VERSION
	s.date         = '2011-07-07'
	s.authors      = ["Daniel P. Wright"]
	s.email        = 'dani@dpwright.com'
	s.homepage     = 'https://github.com/dpwright/srs'
	s.license      = 'Simplified BSD'

	s.summary      = "A highly extensible command-line spaced repetition system"
	s.description  = <<-EOF
	A Spaced Repetition System is a study tool which works by spacing out
	exercises so as to learn in the most efficient manner possible.

	srs is a command-line based implementation of the spaced repetition system.
	It is designed to be highly extensible and to promote the sharing of data
	for study by others.
	EOF

	s.files            = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ }
	s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.rdoc_options     = ["--charset=UTF-8"]
	s.require_path     = "lib"

	s.add_dependency('require_all', '>= 1.2.1')
end
