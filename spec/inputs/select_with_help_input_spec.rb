require 'spec_helper'

describe 'SelectWithHelpInput', type: :input do
  subject { input_for form, :resource_type, options }
  let(:file) { GenericFile.new }
  let(:form) { Sufia::Forms::BatchEditForm.new(file) }
  let(:base_options) do
    { as: :select_with_help, collection: Sufia.config.resource_types,
      input_html: { class: 'form-control', multiple: true } }
  end
  let(:options) { base_options }

  it "is not required by default" do
    expect(subject).to have_selector 'select'
    expect(subject).not_to match(/required/)
  end

  context 'with File Edit', type: :input do
    let(:user) { FactoryGirl.find_or_create(:jill) }
    let(:file) { GenericFile.create(batch: Batch.create, label: 'f1') { |f| f.apply_depositor_metadata(user) } }
    let(:form) { Sufia::Forms::GenericFileEditForm.new(file) }
    let(:base_options) do
      { as: :select_with_help, collection: Sufia.config.resource_types,
        input_html: { class: 'form-control', multiple: true } }
    end
    let(:options) { base_options }

    subject { input_for form, :resource_type, options }

    it "is not required by default" do
      expect(subject).to have_selector 'select'
      expect(subject).not_to match(/required/)
    end
  end
end
