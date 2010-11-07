module Redcar
  module TimeMachine
    class VersionBar < Speedbar
      include Redcar::Observable

      label :text, "Versions:"
      slider :versions_slider
      button :revert_button, "Revert!", nil do
        revert = Application::Dialog.message_box(<<-TEXT.gsub(/^\s*/, ""), :type => :warning, :buttons => :yes_no)
          Depending on your SCM, you might not be able to undo this revert easily.
          Note, that this will only change the file's contents on disk, not commit the changes.

          Are you sure you want to revert to the currently displayed version?
        TEXT
        if revert

        end
      end

      def initialize
        @window   = Redcar.app.focussed_window
        @tab      = @window.focussed_notebook_tab
        get_versions

        @listener = @window.add_listener(:tab_focussed) do |tab|
          @tab = tab
          get_versions
        end
      end

      def close
        Redcar.app.window.remove_listener(@listener)
      end

      def get_versions
        path = @tab.edit_view.document.path
        if path
          versions = git_repo.log("HEAD", path)
          if versions.any?
            versions_slider.minimum = 1
            versions_slider.maximum = versions.count
          end
        end
        versions_slider.enabled = (versions and versions.any?)
      end

      def git_repo
        project_path = Grit::Repo.new(Project::Manager.in_window(@window))
        if @project_path != project_path
          @git_repo = Grit::Repo.new(@project_path)
        end
        @git_repo
      end
    end
  end
end