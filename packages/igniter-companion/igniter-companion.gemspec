Gem::Specification.new do |spec|
  spec.name          = "igniter-companion"
  spec.version       = "0.1.0"
  spec.summary       = "Application-level Record/History DSL backed by igniter-ledger"
  spec.authors       = ["Alexander"]
  spec.require_paths = ["lib"]
  spec.files         = Dir["lib/**/*.rb"]

  spec.add_dependency "igniter-ledger"
  spec.add_dependency "igniter-ledger-client"
end
