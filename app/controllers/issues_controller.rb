class IssuesController < ApplicationController
  def index
   backlog_issue = Issue.in_backlog.find_by_predecessor_id(nil)
    @backlog_issues = []
    if backlog_issue
    @backlog_issues << backlog_issue
      while backlog_issue.descendant do
        backlog_issue = backlog_issue.descendant
        @backlog_issues << backlog_issue
      end
    end
    sprint_issue = Issue.in_sprint.find_by_predecessor_id(nil)
    @sprint_issues = []
    if sprint_issue
    @sprint_issues << sprint_issue
      while sprint_issue.descendant do
        sprint_issue = sprint_issue.descendant
        @sprint_issues << sprint_issue
      end
    end 
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def new
    @issue = Issue.new
    prepare_form
  end

  def edit
    @issue = Issue.find(params[:id])
    prepare_form
  end

  def create
    if params[:issue]
      type = params[:issue][:type]
      if Issue.children_type_names.include? type
        model_class = Kernel.const_get type 
        @issue = model_class.new(params[:issue])
      end
    else
      types = Issue.children_type_names
      @issue = nil
      types.each do |t|
        @type = t.gsub(/(.)([A-Z])/,'\1_\2').downcase
        if params[@type.to_sym]
          model_class = Kernel.const_get t
          @issue = model_class.new(params[@type.to_sym])
          break
        end
      end
    end
    old_first_issue = Issue.in_backlog.find_by_predecessor_id(nil)
    @issue.predecessor_id = nil
    @issue.sprint_flag = false

    if @issue && @issue.save
      if old_first_issue
        old_first_issue.predecessor_id = @issue.id
        old_first_issue.save
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
    if @issue && @issue.update_attributes(params[@type])
      redirect_to issues_path, notice: 'Eintrag erfolgreich bearbeitet.'
    else
      @issue = Issue.find(params[:id])
      prepare_form
      render action: "edit"
    end
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
   moved_issue = Issue.find params[:moved_issue_id]
   backlog_list = params[:backlog_list]
   sprint_backlog_list = params[:sprint_backlog_list]
   if backlog_list == nil 
    backlog_list = Array.new   
   end
   if sprint_backlog_list 
    if sprint_backlog_list.include?(moved_issue.id)
      moved_issue.sprint_flag = true;
      moved_issue.save
    else
      moved_issue.sprint_flag = false;
      moved_issue.save
    end 
   else
    sprint_backlog_list = Array.new
   end
   moved_issue.reload.update_lists backlog_list, sprint_backlog_list
   render :nothing => true
  end

  private

  def prepare_form
    @projects = Project.all(:order => 'name ASC').collect do |project|
      [project.name, project.id]
    end
    a_number = 0
    @types = Issue.children_type_names.map do |name|
      [name, name]
    end
  end
end
