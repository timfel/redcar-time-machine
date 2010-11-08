$LOAD_PATH << File.expand_path("../../../vendor/grit/lib", __FILE__)
require 'grit'
require 'time_machine/version_bar'

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
