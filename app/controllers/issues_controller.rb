class IssuesController < ApplicationController
  def index
    @issues = Issue.all
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
    type = params[:issue][:type]
    if Issue.children_type_names.include? type
      model_class = Kernel.const_get type 
      @issue = model_class.new(params[:issue])
    end

    if @issue && @issue.save
      redirect_to @issue, notice: 'Issue was successfully created.'
    else
      prepare_form
      render action: "new"
    end
  end

  def update
    @issue = Issue.find(params[:id])

    if @issue.update_attributes(params[:issue])
      redirect_to @issue, notice: 'Issue was successfully updated.'
    else
      prepare_form
      render action: "edit"
    end
  end

  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    redirect_to issues_url
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
