require 'spec_helper'

describe Issue do
  it 'has a valid factory' do
    expect(build :issue).to be_valid
  end

  describe 'associations' do
    let(:issue) { Issue.new }

    it 'responds to project' do
      expect(issue).to respond_to(:project)
    end

    it 'responds to project=' do
      expect(issue).to respond_to(:project=)
    end

    it 'responds to predecessor' do
      expect(issue).to respond_to(:predecessor)
    end

    it 'responds to predecessor=' do
      expect(issue).to respond_to(:predecessor=)
    end

    it 'responds to backlog' do
      expect(issue).to respond_to(:backlog)
    end

    it 'responds to backlog=' do
      expect(issue).to respond_to(:backlog=)
    end

    it 'responds to descendant' do
      expect(issue).to respond_to(:descendant)
    end

    it 'responds to descendant=' do
      expect(issue).to respond_to(:descendant=)
    end
  end

  describe 'validations' do
    it 'is invalid without a name' do
      expect(build :issue, name: nil).to be_invalid
    end

    it 'is invalid without a type' do
      expect(build :issue, type: nil).to be_invalid
    end

    it 'is invalid without a project' do
      expect(build :issue, project: nil).to be_invalid
    end

    it 'is invalid without a description' do
      expect(build :issue, description: nil).to be_invalid
    end
  end

  describe '.children_type_names' do
    it "returns an array with ['UserStory', 'Task', 'Bug', 'Document']" do
      expect(Issue.children_type_names).to eq(['UserStory', 'Task', 'Bug', 'Document'])
    end
  end

  describe '#close_gap' do
    let!(:issue1) { create :task }
    let!(:issue2) { create :task, predecessor_id: issue1.id }
    let!(:issue3) { create :task, predecessor_id: issue2.id }

    it 'deletes an issue and close the gap if the first issue of the list is deleted' do
      issue1.reload.destroy

      expect(issue3.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to be_nil
      expect(Issue.exists?(issue1)).to be_false
    end

    it 'deletes an issue and close the gap if the last issue of the list is deleted' do
      issue3.reload.destroy

      expect(issue1.reload.predecessor_id).to be_nil
      expect(issue2.reload.predecessor_id).to eq(issue1.id)
      expect(Issue.exists?(issue3)).to be_false
    end

    it 'deletes an issue and close the gap if an issue from the middle of the list is deleted' do
      issue2.reload.destroy

      expect(issue1.reload.predecessor_id).to be_nil
      expect(issue3.reload.predecessor_id).to eq(issue1.id)
      expect(Issue.exists?(issue2)).to be_false
    end
  end

  describe '#formatted_story_points' do
    let(:issue) { create :user_story }

    context 'given story points' do
      it 'returns "0.5" for 0.5 story points' do
        issue.update(story_points: 0.5)

        expect(issue.formatted_story_points).to eq('0.5')
      end

      it 'returns the story points as string' do
        issue.update(story_points: 5)

        expect(issue.formatted_story_points).to eq('5')
      end
    end

    context 'given no story points' do
      it 'returns an empty string' do
        expect(issue.formatted_story_points).to eq('')
      end
    end
  end

  describe '#finish' do
    let(:project) { create :project, name: 'Projekt1' }
    let(:sprint_backlog) { create :backlog, name: 'sprint_backlog' }
    let(:finished_backlog) { create :backlog, name: 'finished_backlog' }
    let(:issue) { create :task, name: 'Task 1', description: 'Das ist ein toller Task', backlog: sprint_backlog, project: project }
    let(:issue2) { create :bug, name: 'Bug 1', description: 'Das ist ein doofer Bug', backlog: finished_backlog, project: project }

    it 'finishes the only one element in the list' do
      issue.finish

      expect(issue.finished?).to be_true
      expect(issue.in_sprint?).to be_false
    end

    it 'finishes the only unfinished element if one finished exists' do
      issue.finish

      expect(issue.finished?).to be_true
    end

    it 'finishes one of two unfinished elements' do
      issue2.update(backlog: sprint_backlog)

      issue.finish

      expect(issue.finished?).to be_true
    end

    it 'finishes a finished element' do
      issue.update(backlog: finished_backlog)

      issue.finish

      expect(issue.finished?).to be_true
      expect(issue.in_sprint?).to be_false
    end
  end

  describe '#finished?' do
    let(:issue) { create :task }

    it 'returns true if backlog == finished_backlog' do
      issue.update(backlog: Backlog.finished_backlog)

      expect(issue.finished?).to eq(true)
    end

    it 'returns false otherwise' do
      issue.update(backlog: Backlog.backlog)

      expect(issue.finished?).to eq(false)
    end
  end

  describe '#in_sprint?' do
    let(:issue) { create :task }

    it 'returns true if backlog == sprint_backlog' do
      issue.update(backlog: Backlog.sprint_backlog)

      expect(issue.in_sprint?).to eq(true)
    end

    it 'returns false otherwise' do
      issue.update(backlog: Backlog.backlog)

      expect(issue.in_sprint?).to eq(false)
    end
  end

  feature_active? :temp_changes_for_iso do
    describe '#in_backlog?' do
      let(:issue) { create :task }

      it 'returns true if backlog == backlog'  do
        issue.update(backlog: Backlog.backlog)

        expect(issue.in_backlog?).to eq(true)
      end

      it 'returns false otherwise' do
        issue.update(backlog: Backlog.sprint_backlog)

        expect(issue.in_backlog?).to eq(false)
      end
    end
  end

  describe '#done!' do
    let(:issue) { create :task, ready_to_finish: false, done_at: nil }

    before :each do
      issue.done!
    end

    it 'sets ready_to_finish to true' do
      expect(issue.ready_to_finish).to eq(true)
    end

    it 'sets done_at' do
      expect(issue.done_at).to_not eq(nil)
    end
  end

  describe '#doing!' do
    let(:issue) { create :task, ready_to_finish: true, done_at: Time.now }

    before :each do
      issue.doing!
    end

    it 'sets ready_to_finish to false' do
      expect(issue.ready_to_finish).to eq(false)
    end

    it 'sets done_at to nil' do
      expect(issue.done_at).to eq(nil)
    end

    it 'persists the changes' do
      expect(issue.reload.attributes).to include('ready_to_finish' => false, 'done_at' => nil)
    end
  end

  describe '#done?' do
    let(:issue) { create :task }

    it 'returns true if ready_to_finish == true' do
      issue.ready_to_finish = true

      expect(issue.done?).to eq(true)
    end

    it 'returns false otherwise'  do
      issue.ready_to_finish = false

      expect(issue.done?).to eq(false)
    end
  end

  describe '#activate' do
    let(:project) { create :project, name: 'Projekt1' }
    let(:backlog) { create :backlog }
    let(:sprint_backlog) { create :backlog, name: 'sprint_backlog' }
    let(:finished_backlog) { create :backlog, name: 'finished_backlog' }
    let(:issue) { create :task, name: 'Task 1', description: 'Das ist ein toller Task', backlog: finished_backlog, project: project, finished_at: DateTime.new(2014, 10, 31, 17, 0) }
    let(:issue2) { create :user_story, name: 'Story 1', description: 'Das ist eine interessante Geschichte', backlog: backlog, project: project, finished_at: DateTime.new(2014, 10, 31, 17, 0) }

    it 'sets finished_at to nil' do
      issue.activate

      expect(issue.reload.finished_at).to eq(nil)
    end

    it 'activates the only finished element' do
      issue.activate

      expect(issue.finished?).to be_false
      expect(issue.in_sprint?).to be_false
    end

    it 'activates the only finished element if one unfinished in the backlog exists' do
      issue.activate

      expect(issue.finished?).to be_false
      expect(issue.in_sprint?).to be_false
    end

    it 'activates one of two finished elements' do
      issue2.update(backlog: finished_backlog)

      issue.activate

      expect(issue.finished?).to be_false
      expect(issue.in_sprint?).to be_false
    end

    it 'activates the only finished element if one unfinished in the sprint backlog exists' do
      issue2.update(backlog: sprint_backlog)

      issue.activate

      expect(issue.finished?).to be_false
      expect(issue.in_sprint?).to be_false
    end

    it 'activates the only finished element if one unfinished exists in the backlog and one in the sprint backlog' do
      issue3 = create(:bug, name: 'Bug 1', description: 'Das ist ein doofer Bug', backlog: sprint_backlog, project: project)

      issue.activate

      expect(issue.finished?).to be_false
      expect(issue.in_sprint?).to be_false
    end

    it 'activates an unfinished element' do
      issue.update(backlog: backlog)

      issue.activate

      expect(issue.finished?).to be_false
      expect(issue.in_sprint?).to be_false
    end

    context 'with three finished issues' do
      before :each do
        @issue1 = create(:task, backlog: finished_backlog)
        @issue2 = create(:task, backlog: finished_backlog, predecessor: @issue1)
        @issue3 = create(:task, backlog: finished_backlog, predecessor: @issue2)
      end

      it 'removes the predecessor of the second issue when activating the first' do
        @issue1.activate
        @issue2.reload

        expect(@issue2.predecessor).to be_nil
      end

      it 'moves the first issue to the new issues backlog when activating the first' do
        @issue1.activate

        expect(@issue1.backlog).to eq(Backlog.backlog)
      end

      it 'updates the predecessor of the third issue to the first when activating the second' do
        @issue2.activate
        @issue3.reload

        expect(@issue3.predecessor).to eq(@issue1)
      end

      it 'updates the predecessor of the second issue to nil when activating the second' do
        @issue2.activate

        expect(@issue2.predecessor).to be_nil
      end
    end
  end

  describe '#update_attributes' do
    let(:issue) { create :issue }

    it 'increments the lock number' do
      issue.update_attributes(:name => "Changed")

      expect(issue.lock_version).to eq(1)
    end

    it 'throws an error for a stale model' do
      issue1 = Issue.find_by(id: issue.id)
      issue2 = Issue.find_by(id: issue.id)
      issue1.update_attributes(:name => 'Changed first')

      expect { issue2.update_attributes(:name => 'Changed second') }.to raise_error(ActiveRecord::StaleObjectError)
    end
  end

  describe "#move_to" do
    let!(:x) { create :issue, backlog: Backlog.backlog }

    # x ... issue to move
    # 0 ... other issues
    context 'changing priotity of an issue' do
      it '
      Start:  [ x     ]
      Finish: [ x     ]'  do
        x.move_to Backlog.backlog

        x.reload
        expect(x.predecessor).to be_nil
        expect(x.descendant).to be_nil
      end

      it '
      Start:  [ x a   ]
      Finish: [ x a   ]' do
        a = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog

        x.reload
        expect(x.predecessor).to be_nil
        expect(x.descendant).to eq a

        a.reload
        expect(a.predecessor).to eq x
        expect(a.descendant).to be_nil
      end

      it '
      Start:  [ a x   ]
      Finish: [ a x   ]' do
        a = create :issue, backlog: Backlog.backlog
        x.update(predecessor: a)

        x.move_to Backlog.backlog, new_predecessor: a

        x.reload
        expect(x.predecessor).to eq a
        expect(x.descendant).to be_nil

        a.reload
        expect(a.predecessor).to be_nil
        expect(a.descendant).to eq x
      end

      it '
      Start:  [ a x b ]
      Finish: [ a x b ]' do
        a = create :issue, backlog: Backlog.backlog
        x.update(predecessor: a)
        b = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog,  new_predecessor: a

        x.reload
        expect(x.predecessor).to eq a
        expect(x.descendant).to eq b

        a.reload
        expect(a.predecessor).to be_nil
        expect(a.descendant).to eq x

        b.reload
        expect(b.predecessor).to eq x
        expect(b.descendant).to be_nil
      end


      it '
      Start:  [ x a   ]
      Finish: [ a x   ]' do
        a = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog, new_predecessor: a

        x.reload
        expect(x.predecessor).to eq a
        expect(x.descendant).to be_nil

        a.reload
        expect(a.descendant).to eq x
        expect(a.predecessor).to be_nil
      end

      it '
      Start:  [ a x   ]
      Finish: [ x a   ]' do
        a = create :issue, backlog: Backlog.backlog
        x.update(predecessor: a)

        x.move_to Backlog.backlog

        x.reload
        expect(x.predecessor).to be_nil
        expect(x.descendant).to eq a

        a.reload
        expect(a.descendant).to be_nil
        expect(a.predecessor).to eq x
      end

      it '
      Start:  [ x a b ]
      Finish: [ a x b ]' do
        a = create :issue, backlog: Backlog.backlog, predecessor: x
        b = create :issue, backlog: Backlog.backlog, predecessor: a

        x.move_to Backlog.backlog, new_predecessor: a

        x.reload
        expect(x.predecessor).to eq a
        expect(x.descendant).to eq b

        a.reload
        expect(a.descendant).to eq x
        expect(a.predecessor).to be_nil

        b.reload
        expect(b.descendant).to be_nil
        expect(b.predecessor).to eq x
      end

      it '
      Start:  [ a x b ]
      Finish: [ a b x ]' do
        a = create :issue, backlog: Backlog.backlog
        x.update(predecessor: a)
        b = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog, new_predecessor: b

        x.reload
        expect(x.predecessor).to eq b
        expect(x.descendant).to be_nil

        a.reload
        expect(a.descendant).to eq b
        expect(a.predecessor).to be_nil

        b.reload
        expect(b.descendant).to eq x
        expect(b.predecessor).to eq a
      end

      it '
      Start:  [ a b x ]
      Finish: [ a x b ]' do
        a = create :issue, backlog: Backlog.backlog
        b = create :issue, backlog: Backlog.backlog, predecessor: a
        x.update(predecessor: b)

        x.move_to Backlog.backlog, new_predecessor: a

        x.reload
        expect(x.predecessor).to eq a
        expect(x.descendant).to eq b

        a.reload
        expect(a.descendant).to eq x
        expect(a.predecessor).to be_nil

        b.reload
        expect(b.descendant).to be_nil
        expect(b.predecessor).to eq x
      end

      it '
      Start:  [ a b x ]
      Finish: [ x a b ]' do
        a = create :issue, backlog: Backlog.backlog
        b = create :issue, backlog: Backlog.backlog, predecessor: a
        x.update(predecessor: b)

        x.move_to Backlog.backlog

        x.reload
        expect(x.predecessor).to be_nil
        expect(x.descendant).to eq a

        a.reload
        expect(a.descendant).to eq b
        expect(a.predecessor).to eq x

        b.reload
        expect(b.descendant).to be_nil
        expect(b.predecessor).to eq a
      end

      it '
      Start:  [ a x b ]
      Finish: [ x a b ]' do
        a = create :issue, backlog: Backlog.backlog
        x.update(predecessor: a)
        b = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.backlog

        x.reload
        expect(x.predecessor).to be_nil
        expect(x.descendant).to eq a

        a.reload
        expect(a.predecessor).to eq x
        expect(a.descendant).to eq b

        b.reload
        expect(b.predecessor).to eq a
        expect(b.descendant).to be_nil
      end

      it '
      Start:  [ x a b ]
      Finish: [ a b x ]' do
        a = create :issue, backlog: Backlog.backlog, predecessor: x
        b = create :issue, backlog: Backlog.backlog, predecessor: a

        x.move_to Backlog.backlog, new_predecessor: b

        x.reload
        expect(x.predecessor).to eq b
        expect(x.descendant).to be_nil

        a.reload
        expect(a.predecessor).to be_nil
        expect(a.descendant).to eq b

        b.reload
        expect(b.predecessor).to eq a
        expect(b.descendant).to eq x
      end
    end

    feature_active? :temp_changes_for_iso do
      context 'move issue between new_issues_list and product backlog' do
        it '
        Start:  [ x   ][    ]
        Finish: [     ][ x  ]' do
          x = create :issue, backlog: Backlog.new_issues_list
          x.move_to Backlog.backlog
          x.reload

          expect(x.backlog).to eq(Backlog.backlog)
          expect(x.predecessor).to be_nil
        end
      end
    end

    context 'move issue between backlogs' do
      ## test effects on source list
      it '
      Start:  [ x     ] [       ]
      Finish: [       ] [ x     ]' do
        x.move_to Backlog.sprint_backlog
        x.reload

        expect(x.backlog).to eq Backlog.sprint_backlog
        expect(x.predecessor).to be_nil
      end

      it '
      Start:  [ x a   ] [       ]
      Finish: [ a     ] [ x     ]' do
        a = create :issue, backlog: Backlog.backlog, predecessor: x
        x.move_to Backlog.sprint_backlog

        expect(x.backlog).to eq Backlog.sprint_backlog

        a.reload

        expect(a.backlog).to eq Backlog.backlog
        expect(a.predecessor).to be_nil
      end


      it '
      Start:  [ a x   ] [       ]
      Finish: [ a     ] [ x     ]' do
        a = create :issue, backlog: Backlog.backlog
        x.move_to Backlog.sprint_backlog

        expect(x.predecessor).to be_nil
        expect(x.backlog).to eq Backlog.sprint_backlog

        a.reload

        expect(a.backlog).to eq Backlog.backlog
        expect(a.descendant).to be_nil
      end

      it '
      Start:  [ a b x ] [       ]
      Finish: [ a b   ] [ x     ]' do
        a = create :issue, backlog: Backlog.backlog
        b = create :issue, backlog: Backlog.backlog, predecessor: a
        x.update(predecessor: b)

        x.move_to Backlog.sprint_backlog
        expect(x.predecessor).to be_nil
        expect(x.backlog).to eq Backlog.sprint_backlog

        a.reload
        expect(a.descendant).to eq b
        expect(a.predecessor).to be_nil
        expect(a.backlog).to eq Backlog.backlog

        b.reload
        expect(b.predecessor).to eq a
        expect(b.descendant).to be_nil
        expect(b.backlog).to eq Backlog.backlog
      end

      it '
      Start:  [ a x b ] [       ]
      Finish: [ a b   ] [ x     ]' do
        a = create :issue, backlog: Backlog.backlog
        x.update(predecessor: a)
        b = create :issue, backlog: Backlog.backlog, predecessor: x

        x.move_to Backlog.sprint_backlog
        expect(x.predecessor).to be_nil
        expect(x.backlog).to eq Backlog.sprint_backlog

        a.reload
        expect(a.descendant).to eq b
        expect(a.backlog).to eq Backlog.backlog

        b.reload
        expect(b.predecessor).to eq a
        expect(b.backlog).to eq Backlog.backlog
      end

      ## test effects on target list
      it '
      Start:  [ x     ] [ a     ]
      Finish: [       ] [ x a   ]' do
        a = create :issue, backlog: Backlog.sprint_backlog

        x.move_to Backlog.sprint_backlog
        expect(x.predecessor).to be_nil
        expect(x.backlog).to eq Backlog.sprint_backlog

        a.reload
        expect(a.backlog).to eq Backlog.sprint_backlog
        expect(a.predecessor).to eq x

        expect(Backlog.backlog.issues).to be_empty
      end

      it '
      Start:  [ x     ] [ a     ]
      Finish: [       ] [ a x   ]' do
        a = create :issue, backlog: Backlog.sprint_backlog

        x.move_to Backlog.sprint_backlog, new_predecessor: a
        expect(x.backlog).to eq Backlog.sprint_backlog

        x.reload
        expect(x.predecessor).to eq a

        a.reload
        expect(a.predecessor).to be_nil
        expect(a.backlog).to eq Backlog.sprint_backlog
      end

      it '
      Start:  [ x     ] [ a b   ]
      Finish: [       ] [ a x b ]' do
        a = create :issue, backlog: Backlog.sprint_backlog
        b = create :issue, backlog: Backlog.sprint_backlog, predecessor: a

        x.move_to Backlog.sprint_backlog, new_predecessor: a

        x.reload
        expect(x.backlog).to eq Backlog.sprint_backlog
        expect(x.predecessor).to eq a

        a.reload
        expect(a.backlog).to eq Backlog.sprint_backlog
        b.reload

        expect(b.backlog).to eq Backlog.sprint_backlog
        expect(b.predecessor).to eq x
      end
    end

    it 'throws an error if backlog of new predecessor is not the same as the passed backlog' do
      a = create :issue, backlog: Backlog.sprint_backlog

      expect {
        x.move_to Backlog.backlog, new_predecessor: a
      }.to raise_error
    end
  end

  describe '#save_with_lock' do
    let!(:issue) { create :issue, lock_version: 1, backlog: Backlog.backlog }

    after :each do
      LockVersionHelper.lock_version = nil
    end

    context 'when having a lower lock versions in memory than in db' do
      it 'raises an error when having a different lock version' do
        LockVersionHelper.lock_version = { }
        LockVersionHelper.lock_version[issue.id.to_s] = 0

        expect {
          issue.save
        }.to raise_error ActiveRecord::StaleObjectError
      end
    end

    context 'when having the same lock version in memory and db' do
      before :each do
        LockVersionHelper.lock_version = {}
        LockVersionHelper.lock_version[issue.id.to_s] = 1
      end

      it 'saves the issue' do
        issue.update(name: 'Changed')

        issue.reload
        expect(issue.name).to eq('Changed')
      end

      it 'doesnt raise an error' do
        issue.name = 'Changed'

        expect {
          issue.save
        }.not_to raise_error
      end

      it 'increments the lock version in memory' do
        issue.update(name: 'Changed')

        expect(LockVersionHelper.lock_version[issue.id.to_s]).to eq(2)
      end
    end
  end
end