module Redcar
  module TimeMachine
    class VersionBar < Speedbar
      include Redcar::Observable

      label :text, "Versions:"
      slider :versions_slider do |version| checkout(version); end
      button :revert_button, "Revert!", nil do revert!; end

      def initialize
        @window    = Redcar.app.focussed_window
        tab        = @window.focussed_notebook_tab
        @edit_view = tab.edit_view if tab and tab.edit_tab?

        attach_listeners
        get_versions
      end

      def close
        remove_listeners
      end

      def attach_listeners
        @listeners = Hash.new {|h,k| h[k] = [] }
        @listeners[@window] << @window.add_listener(:tab_focussed) do |tab|
          @edit_view = nil
          @edit_view = tab.edit_view if tab.edit_tab?
          get_versions
        end
      end

      def remove_listeners
        @listeners.each_pair do |observable, listeners|
          listeners.each {|l| observable.remove_listener(l) }
        end
      end

      def checkout(version)
        return unless file_path
        idx = git_repo.index
        idx.read_tree @versions[version].sha
        @edit_view.document.text = (idx.current_tree / file_path).data
      end

      def revert!
        return unless @edit_view
        revert = Application::Dialog.message_box(<<-TEXT.gsub(/^[ ]*/, ""), :type => :warning, :buttons => :yes_no)
          Depending on your SCM, you might not be able to undo this revert easily.
          Note, that this will only change the file's contents on disk, not commit the changes.

          Are you sure you want to revert to the currently displayed version?
        TEXT
        @edit_view.document.save! if revert
      end

      def get_versions
        path = @edit_view.document.path if @edit_view
        if path
          @versions = git_repo.log("HEAD", path).reverse
          if @versions.any?
            versions_slider.minimum = 0
            versions_slider.maximum = @versions.count
            versions_slider.value   = @versions.count
          end
        end
        versions_slider.enabled = (path and @versions.any?)
      end

      def git_repo
        project = Project::Manager.in_window(@window)
        if project and @project_path != project.path
          @git_repo = Grit::Repo.new(@project_path = project.path)
        end
        @git_repo
      end

      def file_path
        return @file_path if @file_path
        @file_path = @edit_view.document.path
        @file_path.sub!(File.expand_path(@project_path) + File::SEPARATOR, "")
        @file_path.gsub!(File::SEPARATOR, "/")
      end
    end
  end
end
