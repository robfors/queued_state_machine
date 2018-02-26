Gem::Specification.new do |s|
  s.name        = 'queued_state_machine'
  s.version     = '0.0.1'
  s.date        = '2018-02-25'
  s.summary     = "A state machine supporting reentry."
  s.description = "A state machine that supports queuing any callbacks that are triggered during a callback."
  s.authors     = ["Rob Fors"]
  s.email       = 'mail@robfors.com'  
  s.files       = Dir.glob("{lib,test}/**/*") + %w(LICENSE README.md)
  s.homepage    = 'https://github.com/robfors/ruby-queued_state_machine'
  s.license     = 'MIT'
end
