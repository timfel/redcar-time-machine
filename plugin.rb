Plugin.define do
  name    "time-machine"
  version "0.0.1"
  file    "lib", "time_machine"
  object  "Redcar::TimeMachine"
  dependencies "application", ">=1.2"
end
