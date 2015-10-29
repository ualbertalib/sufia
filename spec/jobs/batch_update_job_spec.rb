require 'spec_helper'

describe BatchUpdateJob do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:batch) { Batch.create }

  let!(:file) do
    GenericFile.new(batch: batch) do |file|
      file.apply_depositor_metadata(user)
      file.save!
    end
  end

  let!(:file2) do
    GenericFile.new(batch: batch) do |file|
      file.apply_depositor_metadata(user)
      file.save!
    end
  end

  describe "#run" do
    let(:title) { { file.id => ['File One'], file2.id => ['File Two'] } }
    let(:metadata) do
      { read_groups_string: '', read_users_string: 'archivist1, archivist2',
        tag: [''] }.with_indifferent_access
    end

    let(:visibility) { nil }

    let(:job) { described_class.new(user.user_key, batch.id, title, metadata, visibility) }

    context "with a failing update" do
      it "checks permissions for each file before updating" do
        expect_any_instance_of(User).to receive(:can?).with(:edit, file).and_return(false)
        expect_any_instance_of(User).to receive(:can?).with(:edit, file2).and_return(false)
        job.run
        expect(user.mailbox.inbox[0].messages[0].subject).to eq("Batch upload permission denied")
        expect(user.mailbox.inbox[0].messages[0].body).to include("data-content")
        expect(user.mailbox.inbox[0].messages[0].body).to include("These files")
      end
    end

    describe "sends events" do
      let(:s1) { double('one') }
      let(:s2) { double('two') }
      it "logs a content update event" do
        expect_any_instance_of(User).to receive(:can?).with(:edit, file).and_return(true)
        expect_any_instance_of(User).to receive(:can?).with(:edit, file2).and_return(true)
        expect(ContentUpdateEventJob).to receive(:new).with(file.id, user.user_key).and_return(s1)
        expect(Sufia.queue).to receive(:push).with(s1).once
        expect(ContentUpdateEventJob).to receive(:new).with(file2.id, user.user_key).and_return(s2)
        expect(Sufia.queue).to receive(:push).with(s2).once
        job.run
        expect(user.mailbox.inbox[0].messages[0].subject).to eq("Batch upload complete")
        expect(user.mailbox.inbox[0].messages[0].body).to include("data-content")
        expect(user.mailbox.inbox[0].messages[0].body).to include("These files")
      end
    end

    describe "updates metadata" do
      before do
        allow(Sufia.queue).to receive(:push)
        job.run
      end

      it "updates the titles" do
        expect(file.reload.title).to eq ['File One']
      end
    end

    describe "embargo visibility" do 
    let(:title) { { file.id => ['File One'], file2.id => ['File Two'] }}
    let(:metadata) do
      { read_groups_string: '', read_users_string: 'archivist1, archivist2',
        subject: [''], date_created: '2012/01/01' 
      }.with_indifferent_access
    end
  
    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
    let(:job) { BatchUpdateJob.new(user.user_key, batch.id, title, metadata, visibility, '2112-01-01', Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC) }

    before do
      allow(Sufia.queue).to receive(:push)
    end

    it 'should work' do
      expect {job.run}.not_to raise_error
      expect(file.reload.under_embargo?).to be true
    end

  end
  end
end
