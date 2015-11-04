require 'spec_helper'
require 'rake'

describe Rake::Task do
  let(:past_date) { 2.days.ago }
  let!(:file) do
    FactoryGirl.build(:generic_file, title: ["tested embargo"], embargo_release_date: past_date.to_s, visibility_after_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC).tap do |work|
      work.apply_depositor_metadata('dittest@ualberta.ca')
      work.save(validate: false)
    end
  end

  before do
    load File.expand_path("../../../tasks/embargo.rake", __FILE__)
  end

  describe "sufia:remove_lapsed_embargoes" do
    before do
      described_class.define_task(:environment)
      described_class["sufia:remove_lapsed_embargoes"].invoke
    end

    after do
      described_class["sufia:remove_lapsed_embargoes"].reenable
      file.delete
    end

    subject { GenericFile.find(file.id) }

    it "clears the expired embargo" do
      expect(subject).not_to be_nil
      # expect(subject.embargo_release_date).to be_nil
      expect(subject.embargo_history).not_to be_nil
      expect(subject.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end
  end
end
