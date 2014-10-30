require 'spec_helper'

describe IssuesController do
  before :each do
    create(:backlog)
    create(:backlog, name: "sprint_backlog")
    create(:backlog, name: "finished_backlog")
  end

  describe 'POST #finish_issue' do
    before :each do
      @issue = FactoryGirl.create :issue, type: "Task", backlog: Backlog.sprint_backlog
    end

    it 'locates the requested issue' do
      pending
      post :finish_issue, id: @issue
      assigns(:issue).should eq(@message)
    end

    it 'moves the issues from the sprint backlog to the finished backlog' do
      post :finish_issue, id: @issue
      @issue.reload
      @issue.backlog.should eq(Backlog.finished_backlog)
    end
  end

  describe 'POST #activate_issue' do
    context 'theirs only one issue finished' do
      before :each do
        @issue = FactoryGirl.create :issue, type: "Task", backlog: Backlog.finished_backlog
      end

      it 'redirects to finished issue list' do
        post :activate_issue, id: @issue
        response.should redirect_to finished_issues_url
      end
    end

    context 'their are two finished issues' do
      before :each do
         @issue1 = FactoryGirl.create :issue, type: "Task", backlog: Backlog.finished_backlog
         @issue2 = FactoryGirl.create :issue, type: "Task", backlog: Backlog.finished_backlog
      end

      it 'redirect to finished issue list when activating the first' do
        post :activate_issue, id: @issue1
        response.should redirect_to finished_issues_url
      end

      it 'redirect to finished issue list when activating the second' do
        post :activate_issue, id: @issue2
        response.should redirect_to finished_issues_url
      end
    end
  end
end