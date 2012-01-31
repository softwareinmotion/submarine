class IssuesController < ApplicationController
  def index
    @issues = Issue.all
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def new
    @issue = Issue.new
    prepare_projects
  end

  def edit
    @issue = Issue.find(params[:id])
    prepare_projects
  end

  def create
    @issue = Issue.new(params[:issue])

    if @issue.save
      redirect_to @issue, notice: 'Issue was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @issue = Issue.find(params[:id])

    if @issue.update_attributes(params[:issue])
      redirect_to @issue, notice: 'Issue was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    redirect_to issues_url
  end

  private

  def prepare_projects
    @projects = Project.all(:order => 'name ASC').collect do |project|
      [project.name, project.id]
    end
  end
end
