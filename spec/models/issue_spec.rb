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
    
    context 'with three finished issues' do
      
      before :each do
        @issue1 = FactoryGirl.create :task, type: "Task", backlog: Backlog.finished_backlog
        @issue2 = FactoryGirl.create :task, type: "Task", backlog: Backlog.finished_backlog, predecessor: @issue1
        @issue3 = FactoryGirl.create :task, type: "Task", backlog: Backlog.finished_backlog, predecessor: @issue2
      end
      
      it "removes the predecessor of the second issue when activating the first" do
        @issue1.activate
        @issue2.reload
        @issue2.predecessor.should be_nil
      end
      
      it "moves the first issue to the new issues backlog when activating the first" do
        @issue1.activate
        @issue1.backlog.should eq(Backlog.backlog)
      end
      
      it "updates the predecessor of the third issue to the first when activating the second" do
        @issue2.activate
        @issue3.reload
        @issue3.predecessor.should eq(@issue1)
      end
      
      it "updates the predecessor of the second issue to nil when activating the second" do
        @issue2.activate
        @issue2.predecessor.should be_nil
      end
      
    end    
  end

  # don't test the framework
  describe "#create" do

    it "starts with lock_version number 0" do
      create(:issue).lock_version.should eq(0)
    end

  end

  describe "#update_attributes" do

    it "increments the lock number" do
      issue = create :issue
      issue.update_attributes :name => "Changed"
      issue.lock_version.should eq(1)
    end

    it "throws an error for a stale model" do
      issue = create :issue
      issue1 = Issue.find_by_id(issue.id)
      issue2 = Issue.find_by_id(issue.id)
      issue1.update_attributes :name => 'Changed first'
      expect { issue2.update_attributes :name => 'Changed second' }.to raise_error(ActiveRecord::StaleObjectError)
    end

  end

  describe "#move_to" do

    # x ... issue to move
    # 0 ... other issues

    context "changing priotity of an issue" do

      it "
      Start:  [ x     ]
      Finish: [ x     ]" do
        x = create :issue, backlog: Backlog.backlog

        x.move_to Backlog.backlog
        
        x.reload
        x.predecessor.should be_nil
        x.descendant.should be_nil
      end

      it "
      Start:  [ x a   ]
      Finish: [ x a   ]" do
        x = create :issue, backlog: Backlog.backlog
        a = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog
        
        x.reload
        x.predecessor.should be_nil
        x.descendant.should eq a

        a.reload
        a.predecessor.should eq x
        a.descendant.should be_nil
      end 

      it "
      Start:  [ a x   ]
      Finish: [ a x   ]" do
        a = create :issue, backlog: Backlog.backlog
        x = create :issue, backlog: Backlog.backlog, predecessor: a

        x.move_to Backlog.backlog, new_predecessor: a
        
        x.reload
        x.predecessor.should eq a
        x.descendant.should be_nil

        a.reload
        a.predecessor.should be_nil
        a.descendant.should eq x
      end  

      it "
      Start:  [ a x b ]
      Finish: [ a x b ]" do
        a = create :issue, backlog: Backlog.backlog
        x = create :issue, backlog: Backlog.backlog, predecessor: a
        b = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog,  new_predecessor: a
        
        x.reload
        x.predecessor.should eq a
        x.descendant.should eq b

        a.reload
        a.predecessor.should be_nil
        a.descendant.should eq x

        b.reload
        b.predecessor.should eq x
        b.descendant.should be_nil
      end


      it "
      Start:  [ x a   ]
      Finish: [ a x   ]" do
        x = create :issue, backlog: Backlog.backlog
        a = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog, new_predecessor: a
        
        x.reload
        x.predecessor.should eq a
        x.descendant.should be_nil

        a.reload
        a.descendant.should eq x
        a.predecessor.should be_nil
      end

      it "
      Start:  [ a x   ]
      Finish: [ x a   ]" do
        a = create :issue, backlog: Backlog.backlog            
        x = create :issue, backlog: Backlog.backlog, predecessor: a

        x.move_to Backlog.backlog

        x.reload
        x.predecessor.should be_nil
        x.descendant.should eq a

        a.reload
        a.descendant.should be_nil
        a.predecessor.should eq x
      end

      it "
      Start:  [ x a b ]
      Finish: [ a x b ]" do
        x = create :issue, backlog: Backlog.backlog
        a = create :issue, backlog: Backlog.backlog, predecessor: x            
        b = create :issue, backlog: Backlog.backlog, predecessor: a

        x.move_to Backlog.backlog, new_predecessor: a

        x.reload
        x.predecessor.should eq a
        x.descendant.should eq b

        a.reload
        a.descendant.should eq x
        a.predecessor.should be_nil

        b.reload
        b.descendant.should be_nil
        b.predecessor.should eq x
      end

      it "
      Start:  [ a x b ]
      Finish: [ a b x ]" do
        a = create :issue, backlog: Backlog.backlog 
        x = create :issue, backlog: Backlog.backlog, predecessor: a            
        b = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog, new_predecessor: b

        x.reload
        x.predecessor.should eq b
        x.descendant.should be_nil

        a.reload
        a.descendant.should eq b
        a.predecessor.should be_nil

        b.reload
        b.descendant.should eq x
        b.predecessor.should eq a
      end

      it "
      Start:  [ a b x ]
      Finish: [ a x b ]" do
        a = create :issue, backlog: Backlog.backlog            
        b = create :issue, backlog: Backlog.backlog, predecessor: a
        x = create :issue, backlog: Backlog.backlog, predecessor: b

        x.move_to Backlog.backlog, new_predecessor: a

        x.reload
        x.predecessor.should eq a
        x.descendant.should eq b

        a.reload
        a.descendant.should eq x
        a.predecessor.should be_nil

        b.reload
        b.descendant.should be_nil
        b.predecessor.should eq x
      end
      
      it "
      Start:  [ a b x ]
      Finish: [ x a b ]" do
        a = create :issue, backlog: Backlog.backlog            
        b = create :issue, backlog: Backlog.backlog, predecessor: a
        x = create :issue, backlog: Backlog.backlog, predecessor: b

        x.move_to Backlog.backlog

        x.reload
        x.predecessor.should be_nil
        x.descendant.should eq a

        a.reload
        a.descendant.should eq b
        a.predecessor.should eq x

        b.reload
        b.descendant.should be_nil
        b.predecessor.should eq a
      end

      it "
      Start:  [ a x b ]
      Finish: [ x a b ]" do
        a = create :issue, backlog: Backlog.backlog            
        x = create :issue, backlog: Backlog.backlog, predecessor: a
        b = create :issue, backlog: Backlog.backlog, predecessor: x
        

        x.move_to Backlog.backlog

        x.reload
        x.predecessor.should be_nil
        x.descendant.should eq a

        a.reload
        a.predecessor.should eq x
        a.descendant.should eq b

        b.reload
        b.predecessor.should eq a
        b.descendant.should be_nil
      end

      it "
      Start:  [ x a b ]
      Finish: [ a b x ]" do
        x = create :issue, backlog: Backlog.backlog            
        a = create :issue, backlog: Backlog.backlog, predecessor: x
        b = create :issue, backlog: Backlog.backlog, predecessor: a
        
        x.move_to Backlog.backlog, new_predecessor: b

        x.reload
        x.predecessor.should eq b
        x.descendant.should be_nil

        a.reload
        a.predecessor.should be_nil
        a.descendant.should eq b

        b.reload
        b.predecessor.should eq a
        b.descendant.should eq x
      end

    end

    context "move issue between backlogs" do

      ## test effects on source list
      it "
      Start:  [ x     ] [       ]
      Finish: [       ] [ x     ]" do
        x = create :issue, backlog: Backlog.backlog
        x.move_to Backlog.sprint_backlog
        x.reload
        x.backlog.should eq Backlog.sprint_backlog
        x.predecessor.should be_nil
      end
      
      it "
      Start:  [ x a   ] [       ]
      Finish: [ a     ] [ x     ]" do
        x = create :issue, backlog: Backlog.backlog
        a = create :issue, backlog: Backlog.backlog, predecessor: x
        x.move_to Backlog.sprint_backlog 
        x.backlog.should eq Backlog.sprint_backlog
        a.reload
        a.backlog.should eq Backlog.backlog
        a.predecessor.should be_nil
      end


      it "
      Start:  [ a x   ] [       ]
      Finish: [ a     ] [ x     ]" do
        a = create :issue, backlog: Backlog.backlog
        x = create :issue, backlog: Backlog.backlog
        x.move_to Backlog.sprint_backlog
        x.predecessor.should be_nil
        x.backlog.should eq Backlog.sprint_backlog
        a.reload
        a.backlog.should eq Backlog.backlog
        a.descendant.should be_nil        
      end

      it "
      Start:  [ a b x ] [       ] 
      Finish: [ a b   ] [ x     ]" do
        a = create :issue, backlog: Backlog.backlog
        b = create :issue, backlog: Backlog.backlog, predecessor: a
        x = create :issue, backlog: Backlog.backlog, predecessor: b

        x.move_to Backlog.sprint_backlog
        x.predecessor.should be_nil
        x.backlog.should eq Backlog.sprint_backlog
        
        a.reload
        a.descendant.should eq b
        a.predecessor.should be_nil
        a.backlog.should eq Backlog.backlog
        
        b.reload
        b.predecessor.should eq a
        b.descendant.should be_nil
        b.backlog.should eq Backlog.backlog
      end

      it "
      Start:  [ a x b ] [       ] 
      Finish: [ a b   ] [ x     ]" do
        a = create :issue, backlog: Backlog.backlog
        x = create :issue, backlog: Backlog.backlog, predecessor: a
        b = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.sprint_backlog
        x.predecessor.should be_nil
        x.backlog.should eq Backlog.sprint_backlog
        
        a.reload
        a.descendant.should eq b
        a.backlog.should eq Backlog.backlog
        
        b.reload
        b.predecessor.should eq a
        b.backlog.should eq Backlog.backlog
      end
      

      ## test effects on target list
      it "
      Start:  [ x     ] [ a     ]
      Finish: [       ] [ x a   ]" do
        x = create :issue, backlog: Backlog.backlog
        a = create :issue, backlog: Backlog.sprint_backlog

        x.move_to Backlog.sprint_backlog
        x.predecessor.should be_nil
        x.backlog.should eq Backlog.sprint_backlog

        a.reload
        a.backlog.should eq Backlog.sprint_backlog
        a.predecessor.should eq x

        Backlog.backlog.issues.should be_empty
      end

      it "
      Start:  [ x     ] [ a     ]
      Finish: [       ] [ a x   ]" do
        x = create :issue, backlog: Backlog.backlog
        a = create :issue, backlog: Backlog.sprint_backlog

        x.move_to Backlog.sprint_backlog, new_predecessor: a
        x.backlog.should eq Backlog.sprint_backlog

        x.reload
        x.predecessor.should eq a

        a.reload
        a.predecessor.should be_nil
        a.backlog.should eq Backlog.sprint_backlog
      end

      it "      
      Start:  [ x     ] [ a b   ]
      Finish: [       ] [ a x b ]" do
        x = create :issue, backlog: Backlog.backlog
        a = create :issue, backlog: Backlog.sprint_backlog
        b = create :issue, backlog: Backlog.sprint_backlog, predecessor: a

        x.move_to Backlog.sprint_backlog, new_predecessor: a

        x.reload
        x.backlog.should eq Backlog.sprint_backlog
        x.predecessor.should eq a

        a.reload
        a.backlog.should eq Backlog.sprint_backlog
        b.reload

        b.backlog.should eq Backlog.sprint_backlog
        b.predecessor.should eq x
      end
    end

    it "throws an error if backlog of new predecessor is not the same as the passed backlog" do
      x = create :issue, backlog: Backlog.backlog
      a = create :issue, backlog: Backlog.sprint_backlog


      expect {
        x.move_to Backlog.backlog, new_predecessor: a
      }.to raise_error 

    end

  end
  
  describe '#save_with_lock' do
    before :each do
      @issue = create :issue, lock_version: 1, backlog: Backlog.backlog
    end

    after :each do
      LockVersionHelper.lock_version = nil
    end

    context "when having a lower lock versions in memory than in db" do
      
      it "raises an error when having a different lock version" do
        LockVersionHelper.lock_version = { }
        LockVersionHelper.lock_version[@issue.id.to_s] = 0

        expect {
          @issue.save
        }.to raise_error ActiveRecord::StaleObjectError
      end

    end

    context "when having the same lock version in memory and db" do
      before :each do
        LockVersionHelper.lock_version = {}
        LockVersionHelper.lock_version[@issue.id.to_s] = 1
      end

      it "saves the issue" do
        @issue.name = "Changed"
        @issue.save

        @issue.reload
        @issue.name.should eq "Changed"    
      end
      
      it "doesn't raise an error" do
        @issue.name = "Changed"

        expect {
          @issue.save
        }.not_to raise_error
      end
      
      it "increments the lock version in memory" do
        @issue.name = "Changed"
        @issue.save

        LockVersionHelper.lock_version[@issue.id.to_s].should be 2
      end

    end
  end

end
