require 'spec_helper'

describe Issue do
  describe '#close_gap' do
    it 'should delete an issue and close the gap if the first issue of the list is deleted' do 
      issue1 = FactoryGirl.create :issue, type: "Task"
      issue2 = FactoryGirl.create :issue, type: "Task", predecessor_id: issue1.id
      issue3 = FactoryGirl.create :issue, type: "Task", predecessor_id: issue2.id
      
      issue1.reload.destroy
      
      issue3.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should be_nil
      Issue.exists?(issue1).should be_false
    end

    it 'should delete an issue and close the gap if the last issue of the list is deleted' do 
      issue1 = FactoryGirl.create :issue, type: "Task"
      issue2 = FactoryGirl.create :issue, type: "Task", predecessor_id: issue1.id
      issue3 = FactoryGirl.create :issue, type: "Task", predecessor_id: issue2.id
      
      issue3.reload.destroy
      
      issue1.reload.predecessor_id.should be_nil
      issue2.reload.predecessor_id.should == issue1.id
      Issue.exists?(issue3).should be_false
    end

    it 'should delete an issue and close the gap if an issue from the middle of the list is deleted' do 
      issue1 = FactoryGirl.create :issue, type: "Task"
      issue2 = FactoryGirl.create :issue, type: "Task", predecessor_id: issue1.id
      issue3 = FactoryGirl.create :issue, type: "Task", predecessor_id: issue2.id
      
      issue2.reload.destroy
      
      issue1.reload.predecessor_id.should be_nil
      issue3.reload.predecessor_id.should == issue1.id
      Issue.exists?(issue2).should be_false
    end
  end
  
  describe '#finish' do
    before :all do
      @backlog = Backlog.backlog
      @sprint_backlog = Backlog.sprint_backlog
      @finished_backlog = Backlog.finished_backlog
    end

    it 'should finish the only one element in the list' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @sprint_backlog, project: project

      issue.finish

      issue.finished?.should be_true
      issue.in_sprint?.should be_false
    end

    it 'should finish the only unfinished element if one finished exists' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @sprint_backlog, project: project
      issue2 = Bug.create name: 'Bug 1', description: 'Das ist ein doofer Bug', backlog_id: @finished_backlog, project: project

      issue1.finish

      issue1.finished?.should be_true
    end

    it 'should finish one of two unfinished elements' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @sprint_backlog, project: project
      issue2 = Bug.create name: 'Bug 1', description: 'Das ist ein doofer Bug', backlog_id: @sprint_backlog, project: project

      issue1.finish

      issue1.finished?.should be_true
    end

    it 'should finish a finished element' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @finished_backlog, project: project

      issue.finish

      issue.finished?.should be_true
      issue.in_sprint?.should be_false
    end
  end
  
  describe '#activate' do
    it 'should activate the only finished element' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @finished_backlog, project: project

      issue.activate

      issue.finished?.should be_false
      issue.in_sprint?.should be_false
    end

    it 'should activate the only finished element if one unfinished in the backlog exists' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @finished_backlog, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', backlog_id: @backlog, project: project

      issue1.activate

      issue1.finished?.should be_false
      issue1.in_sprint?.should be_false
    end

    it 'should activate one of two finished elements' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @finished_backlog, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', backlog_id: @finished_backlog, project: project

      issue1.activate

      issue1.finished?.should be_false
      issue1.in_sprint?.should be_false
    end

    it 'should activate the only finished element if one unfinished in the sprint backlog exists' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @finished_backlog, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', backlog_id: @sprint_backlog, project: project

      issue1.activate

      issue1.finished?.should be_false
      issue1.in_sprint?.should be_false
    end

    it 'should activate the only finished element if one unfinished exists in the backlog and one in the sprint backlog' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @finished_backlog, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', backlog_id: @backlog, project: project
      issue3 = Bug.create name: 'Bug 1', description: 'Das ist ein doofer Bug', backlog_id: @sprint_backlog, project: project

      issue1.activate

      issue1.finished?.should be_false
      issue1.in_sprint?.should be_false
    end

    it 'should activate an unfinished element' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', backlog_id: @backlog, project: project

      issue.activate

      issue.finished?.should be_false
      issue.in_sprint?.should be_false
    end
  end
end
