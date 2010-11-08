module Redcar
  module TimeMachine
    class VersionBar < Speedbar
      include Redcar::Observable

      label :text, "Versions:"
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
        @window    = Redcar.app.focussed_window
        tab        = @window.focussed_notebook_tab
        @edit_view = tab.edit_view if tab.edit_tab?
        create_slider
        get_versions

        @listener = @window.add_listener(:tab_focussed) do |tab|
          @edit_view = nil
          @edit_view = tab.edit_view if tab.edit_tab?
          get_versions
        end
      end

      def close
        @window.remove_listener(@listener)
      end

      def create_slider
        self.class.slider :versions_slider, &method(:revert_to)
      end

      def revert_to(version)
        return unless @edit_view.document.path
        idx = git_repo.index
        file_path = @edit_view.document.path.sub(@project_path, "")
        idx.read_tree @versions[version - 1].sha
        @edit_view.document.text = (idx.current_tree / file_path).data
      end

      def get_versions
        path = @edit_view.document.path if @edit_view
        if path
          @versions = git_repo.log("HEAD", path).reverse
          if @versions.any?
            versions_slider.minimum = 1
            versions_slider.maximum = @versions.count
            versions_slider.value   = @versions.count
          end
        end
        versions_slider.enabled = (@versions and @versions.any?)
      end

      def git_repo
        project_path = Project::Manager.in_window(@window).path
        if @project_path != project_path
          @git_repo = Grit::Repo.new(@project_path = project_path)
        end
        @git_repo
      end
    end
  end
end
