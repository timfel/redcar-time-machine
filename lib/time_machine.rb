require 'time_machine/time_machine_bar'

module Redcar
  module TimeMachine

    def self.menus
      Redcar::Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "Time Machine" do
            item "Time Machine Bar", :command => OpenVersionBar
          end
        end
      end
    end

    class OpenVersionBar < Command
      def execute
        window = Redcar.app.focussed_window
        speedbar = Redcar::TimeMachine::VersionBar.new
        window.open_speedbar(speedbar)
      end
    end
  end
end
