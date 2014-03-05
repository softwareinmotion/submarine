class IssuesController < ApplicationController

  def index
    @backlog_issues = sorted_list(Backlog.backlog.first_issue)
    @sprint_issues = sorted_list(Backlog.sprint_backlog.first_issue)
    extension_whitelist
  end

  def new
    @issue = Issue.new
    extension_whitelist
    prepare_form
  end

  def edit
    @issue = Issue.find(params[:id])
    extension_whitelist
    prepare_form
  end

  def create
    if params[:issue]
      type = params[:issue][:type]
      if Issue.children_type_names.include? type
        model_class = Kernel.const_get type
        params[:issue][:story_points] = nil if params[:issue][:story_points] == 'unknown'
        @issue = model_class.new(issue_params(:issue))
      end
    else
      types = Issue.children_type_names
      @issue = nil
      types.each do |t|
        @type = t.gsub(/(.)([A-Z])/,'\1_\2').downcase
        if params[@type.to_sym]
          model_class = Kernel.const_get t
          @issue = model_class.new(issue_params(@type.to_sym))
          params[@type.to_sym][:story_points] = nil if params[@type.to_sym][:story_points] == 'unknown'
          break
        end
      end
    end

    if @issue
      old_first_issue = Backlog.backlog.first_issue
      Backlog.backlog.issues << @issue
      @issue.predecessor_id = nil
    end

    if @issue && @issue.save
      if old_first_issue
        old_first_issue.predecessor_id = @issue.id
        old_first_issue.save!
      end
      redirect_to issues_path, notice: 'Eintrag erfolgreich erstellt.'
    else
      prepare_form
      render action: "new"
    end
  end

  def update
    types = Issue.children_type_names
    @issue = nil
    types.each do |t|
      @type = t.gsub(/(.)([A-Z])/,'\1_\2').downcase
      if params[@type]
        @issue = Issue.find(params[:id])
        new_type = params[@type].delete :type
        @issue[:type] = new_type
        break
      end
    end
    params[@type][:story_points] = nil if params[@type][:story_points] == 'unknown'

    if @issue && @issue.update_attributes(issue_params(@type))
      redirect_to issues_path, notice: 'Eintrag erfolgreich bearbeitet.'
    else
      prepare_form
      @issue.errors[:base] << 'Der Eintrag konnte nicht abgespeichert werden, da er zwischenzeitlich bearbeitet wurde.'
      render action: "edit"
    end

  rescue ActiveRecord::StaleObjectError
    prepare_form
    @issue.errors[:base] << 'Der Eintrag konnte nicht abgespeichert werden, da er zwischenzeitlich bearbeitet wurde.'
    render action: "edit"
  end

  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    redirect_to issues_url
  end

  # moves backlog_item from one backlog to the other backlog
  #
  # @param [JSON-string] params[] moved item, backlog list, sprint backlog list
  # example:
  # {"moved_issue_id" => "3",
  # "backlog_list" => [[0] "4",[1] "1",[2] "2"],
  # "sprint_backlog_list" => [[0] "3"]}
  def change_list
    moved_issue = Issue.find params[:moved_issue]
    predecessor = params[:predecessor] ? Issue.find(params[:predecessor]) : nil
    backlog = Backlog.find_by_name params[:backlog]
    LockVersionHelper::lock_version = params[:lock_versions]
    if predecessor
      moved_issue.move_to backlog, new_predecessor: predecessor
    else
      moved_issue.move_to backlog
    end
    moved_issue.ready_to_finish = false
    moved_issue.save
    render :json => LockVersionHelper::lock_version
  ensure
    LockVersionHelper::lock_version = nil
  end

  def finish_issue
    issue = Issue.find(params[:id])
    issue.finish
    issue.finished_at = Time.now
    issue.save
    redirect_to issues_path
  end

  def finished_issues_list
    @finished_issues = sorted_list Backlog.finished_backlog.first_issue
  end

  def activate_issue
    issue = Issue.find(params[:id])
    issue.activate
    redirect_to finished_issues_url
  end

  def status_handler
    issue = Issue.find(params[:id])
    if issue.ready_to_finish == true
      issue.ready_to_finish = false
    else
      issue.ready_to_finish = true
    end
    issue.save
    redirect_to issues_path
  end

  def extension_whitelist
    @extension_whitelist = ['.jpg', '.jpeg', '.png', '.bmp', '.gif']
  end

  def file_attachment
    issue = Issue.find(params[:id])
    send_data issue.file_attachment.read, filename: issue.file_attachment.file.filename
  end

  private

  def prepare_form
    @projects = Project.all(:order => 'name ASC').collect do |project|
      [project.name, project.id, project.project_icon_url]
    end
    a_number = 0
    @types = Issue.children_type_names.map do |name|
      name
    end
    @story_points = ['unknown', 0, 0.5, 1, 2, 3, 5, 8, 13, 20]
  end

  def sorted_list element
    issues = []
    if element
      issues << element
      while element.descendant do
        element = element.descendant
        issues << element
      end
    end
    issues
  end

  def issue_params type
    params.require(type).permit("name", "description", "story_points", "project_id", "lock_version")
  end

end
