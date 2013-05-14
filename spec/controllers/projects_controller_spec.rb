require 'spec_helper'

describe ProjectsController do
  before :each do
    create(:backlog)
    create(:backlog, name: "sprint_backlog")
    create(:backlog, name: "finished_backlog")
  end

  let(:project) { create(:project)}

  describe '#index' do
    it "returns http success" do
      get :index
      response.should be_success
    end

    it "offers all existing projects" do
      create_list(:project, 3)
      get :index
      assigns(:projects).should eq(Project.all)
    end
  end

  describe "#edit" do
    it 'assigns the requested project to @project' do
      get :edit, id: project
      assigns(:project).should be_eql project
    end
  end  

  describe "#new" do
    it "renders the new template" do
      get :new
      response.should render_template :new
    end

    it "assigns a new project to @project" do
      get :new
      assigns(:project).should be_a_new(Project)
    end
  end

  describe "#create" do
    context "with valid params" do
      it "creates a new Projekt" do
        expect {
          post :create, project: attributes_for(:project, name: "Test")
        }.to change(Project, :count).from(0).to(1)
      end

      it "redirects to project index page" do
        post :create, project: attributes_for(:project, name: "Test")
        response.should redirect_to projects_path
      end
    end
  end

  describe '#destroy' do
    it "deletes the selected project" do
      create(:project)
      delete :destroy, id: project
      expect(Project.exists?(project)).to be_false
    end
  end

  describe '#update' do
    it 'updates the selected project' do
      
    end
  end
end