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
  
  describe '#update_lists' do
    it 'should move the third element to the second position within the backlog list' do 
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"

      backlog_issue_array = [issue1.id, issue3.id, issue2.id]
      
      issue3.update_lists backlog_issue_array, Array.new
      
      issue2.reload.predecessor_id.should == issue3.id
      issue3.reload.predecessor_id.should == issue1.id
      issue1.reload.predecessor_id.should be_nil
    end
    
    it 'should move the second element to the first position within the backlog list' do
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
     
      backlog_issue_array = [issue2.id, issue1.id, issue3.id]
      
      issue2.update_lists backlog_issue_array, Array.new
      
      issue3.reload.predecessor_id.should == issue1.id
      issue1.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should be_nil
    end
    
    it 'should move the first element to the last position within the backlog list' do
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
     
      backlog_issue_array = [issue2.id, issue3.id, issue1.id]
      
      issue1.update_lists backlog_issue_array, Array.new
      
      issue1.reload.predecessor_id.should == issue3.id
      issue3.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should be_nil
    end
    
    it 'should move the third element to the first position within the sprint backlog list' do 
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"

      sprint_backlog_issue_array = [issue3.id, issue1.id, issue2.id]
      
      issue3.update_lists Array.new, sprint_backlog_issue_array
      
      issue2.reload.predecessor_id.should == issue1.id
      issue1.reload.predecessor_id.should == issue3.id
      issue3.reload.predecessor_id.should be_nil
    end
    
    it 'should move the third element to the first position and change the second position with the third position within the sprint backlog list' do
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
     
      sprint_backlog_issue_array = [issue3.id, issue2.id, issue1.id]
      
      issue3.update_lists Array.new, sprint_backlog_issue_array
      
      issue1.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should == issue3.id
      issue3.reload.predecessor_id.should be_nil
    end
    
    it 'should move the third element of the backlog list to the second position of the sprint backlog list' do
      issue5 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue4 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      
      # should move issue3 to the sprint backlog list
      issue3.sprint_flag = "true"
      issue3.predecessor_id = issue4.id
      issue3.save
      
      sprint_backlog_issue_array = [issue4.id, issue3.id, issue5.id]
      backlog_issue_array = [issue1.id, issue2.id]

      issue3.update_lists backlog_issue_array, sprint_backlog_issue_array
      
      issue2.reload.predecessor_id.should == issue1.id
      issue1.reload.predecessor_id.should be_nil
      
      issue5.reload.predecessor_id.should == issue3.id
      issue3.reload.predecessor_id.should == issue4.id
      issue4.reload.predecessor_id.should be_nil
    end
    
    it 'should move the last element of the sprint backlog list to the first position of the backlog list' do
      issue5 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue4 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      
      # should move issue5 to the backlog list
      issue5.sprint_flag = "false"
      issue5.predecessor_id = nil
      issue5.save
      
      sprint_backlog_issue_array = [issue4.id]
      backlog_issue_array = [issue5.id, issue1.id, issue2.id, issue3.id]
      
      issue5.update_lists backlog_issue_array, sprint_backlog_issue_array
      
      issue3.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should == issue1.id
      issue1.reload.predecessor_id.should == issue5.id
      issue5.reload.predecessor_id.should be_nil
      
      issue4.reload.predecessor_id.should be_nil
    end
    
    it 'should move the last element of the sprint backlog list to the second position of the backlog list and than the first' +
       'element of the sprint backlog list to the 4th position of the backlog list' do
      issue5 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue4 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      
      # should move issue5 on the second poition of the backlog list 
      issue5.sprint_flag = "false"
      issue5.predecessor_id = issue1.id
      issue5.save
      
      sprint_backlog_issue_array = [issue4.id]
      backlog_issue_array = [issue1.id, issue5.id, issue2.id, issue3.id]
      
      issue5.update_lists backlog_issue_array, sprint_backlog_issue_array
      
      issue3.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should == issue5.id
      issue5.reload.predecessor_id.should == issue1.id
      issue1.reload.predecessor_id.should be_nil
      
      issue4.reload.predecessor_id.should be_nil
      
      # should move issue4 on the 4th poition of the backlog list => sprint backlog list should be empty
      issue4.sprint_flag = "false"
      issue4.predecessor_id = issue2.id
      issue4.save
      
      backlog_issue_array = [issue1.id, issue5.id, issue2.id, issue4.id, issue3.id]
      
      issue4.update_lists backlog_issue_array, Array.new
      
      issue3.reload.predecessor_id.should == issue4.id
      issue4.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should == issue5.id
      issue5.reload.predecessor_id.should == issue1.id
      issue1.reload.predecessor_id.should be_nil
      
      sprint_backlog_issue_array = Issue.in_sprint
      sprint_backlog_issue_array.should == []
    end
    
    it 'should move the last element of the backlog list to the second position of the sprint backlog list and than the first' +
       'element of the backlog list to the last position of the sprint backlog list' do
      issue4 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      issue3 = FactoryGirl.create :issue, type: "Task", sprint_flag: "true"
      
      issue2 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      issue1 = FactoryGirl.create :issue, type: "Task", sprint_flag: "false"
      
      # should move issue2 on the second position of the sprint backlog list
      issue2.sprint_flag = "true"
      issue2.predecessor_id = issue3.id
      issue2.save
      
      sprint_backlog_issue_array = [issue3.id, issue2.id, issue4.id]
      backlog_issue_array = [issue1.id]
      
      issue2.update_lists backlog_issue_array, sprint_backlog_issue_array
      
      issue1.reload.predecessor_id.should be_nil
      
      issue4.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should == issue3.id
      issue3.reload.predecessor_id.should be_nil
      
      # should move issue1 to the last position of the sprint backlog list => backlog list should be empty
      issue1.sprint_flag = "true"
      issue1.predecessor_id = issue4.id
      issue1.save
      
      sprint_backlog_issue_array = [issue3.id, issue2.id, issue4.id, issue1.id]
      
      issue1.update_lists Array.new, sprint_backlog_issue_array
      
      issue1.reload.predecessor_id.should == issue4.id
      issue4.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should == issue3.id
      issue3.reload.predecessor_id.should be_nil
      
      backlog_issue_array = Issue.in_backlog
      backlog_issue_array.should == []
    end
  end
  
  describe '#finish' do
    it 'should finish the only one element in the list' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: false, sprint_flag: true, project: project

      issue.finish

      issue.finished.should be_true
      issue.sprint_flag.should be_false
    end

    it 'should finish the only unfinished element if one finished exists' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: false, sprint_flag: true, project: project
      issue2 = Bug.create name: 'Bug 1', description: 'Das ist ein doofer Bug', finished: true, sprint_flag: true, project: project

      issue1.finish

      issue1.finished.should be_true
    end

    it 'should finish one of two unfinished elements' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: false, sprint_flag: true, project: project
      issue2 = Bug.create name: 'Bug 1', description: 'Das ist ein doofer Bug', finished: false, sprint_flag: true, project: project

      issue1.finish

      issue1.finished.should be_true
    end

    it 'should finish a finished element' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: true, sprint_flag: true, project: project

      issue.finish

      issue.finished.should be_true
      issue.sprint_flag.should be_false
    end
  end
  
  describe '#activate' do
    it 'should activate the only finished element' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: true, sprint_flag: false, project: project

      issue.activate

      issue.finished.should be_false
      issue.sprint_flag.should be_false
    end

    it 'should activate the only finished element if one unfinished in the backlog exists' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: true, sprint_flag: false, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', finished: false, sprint_flag: false, project: project

      issue1.activate

      issue1.finished.should be_false
      issue1.sprint_flag.should be_false
    end

    it 'should activate one of two finished elements' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: true, sprint_flag: false, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', finished: true, sprint_flag: false, project: project

      issue1.activate

      issue1.finished.should be_false
      issue1.sprint_flag.should be_false
    end

    it 'should activate the only finished element if one unfinished in the sprint backlog exists' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: true, sprint_flag: false, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', finished: false, sprint_flag: true, project: project

      issue1.activate

      issue1.finished.should be_false
      issue1.sprint_flag.should be_false
    end

    it 'should activate the only finished element if one unfinished exists in the backlog and one in the sprint backlog' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue1 = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: true, sprint_flag: false, project: project
      issue2 = UserStory.create name: 'Story 1', description: 'Das ist eine interessante Geschichte', finished: false, sprint_flag: false, project: project
      issue3 = Bug.create name: 'Bug 1', description: 'Das ist ein doofer Bug', finished: false, sprint_flag: true, project: project

      issue1.activate

      issue1.finished.should be_false
      issue1.sprint_flag.should be_false
    end

    it 'should activate an unfinished element' do
      project = FactoryGirl.create :project, name: 'Projekt1'
      issue = Task.create name: 'Task 1', description: 'Das ist ein toller Task', finished: false, sprint_flag: false, project: project

      issue.activate

      issue.finished.should be_false
      issue.sprint_flag.should be_false
    end
  end
end
