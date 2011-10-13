$LOAD_PATH << File.expand_path("../../vendor/grit/lib", __FILE__)
require 'grit'
require 'time_machine/version_bar'

module Redcar
  module TimeMachine

    def self.sensitivities
      [ Sensitivity.new(:open_version_bar, Redcar.app, false, [:window_focussed]) do |window|
          Project::Manager.focussed_project
        end ]
    end

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
      sensitize :open_version_bar

      def execute
        window = Redcar.app.focussed_window
        speedbar = Redcar::TimeMachine::VersionBar.new
        window.open_speedbar(speedbar)
      end
    end
  end
end
