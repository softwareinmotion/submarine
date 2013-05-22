# encoding: utf-8
class ProjectsController < ApplicationController 
  def index 
    @projects = Project.all
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to projects_path, :notice => 'Projekt erfolgreich angelegt!'
    else
      render :action => "new"
    end
  end

  def new
    @project = Project.new(params[:name])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @projects = Project.find(params[:id])
    if @projects.update_attributes(params[:project])
      redirect_to projects_path, :notice => 'Erfolgreich Editiert'
    else
      flash[:error] = 'User was not updated.'
      render :action => 'edit'
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, :notice => 'Erfolgreich Gelöscht'
  end
end