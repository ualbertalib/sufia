require 'spec_helper'

describe "Editing a file:", type: :feature do
  let(:user) { FactoryGirl.create(:user) }
  let(:file_title) { 'Some kind of title' }
  let(:file) do
    GenericFile.new.tap do |f|
      f.title = [file_title]
      f.apply_depositor_metadata(user.user_key)
      f.read_groups = ['public']
      f.save!
    end
  end

  before { sign_in user }

  context 'when the user tries to update file content, but forgets to select a file:' do
    it 'displays an error' do
      visit sufia.edit_generic_file_path(file)
      click_link 'Versions'
      click_button 'Upload New Version'
      expect(page).to have_content "Edit #{file_title}"
      expect(page).to have_content 'Please select a file'
    end
  end

  context 'edit form', :type => :feature do

    after :all do
      cleanup_jetty
    end

    before :each do 
      sign_in user 
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
    
    it "should allow for setting an embargo" do
      click_link 'Permissions'
      choose 'visibility_embargo'
      select 'Private', from: 'visibility_during_embargo'
      select 'Open Access', from: 'visibility_after_embargo'
      fill_in 'embargo_release_date', with: '2020-01-01' 
      click_button 'Save'
      visit "/files/#{file.id}"
      expect(page).to have_content "Embargo"
      expect(file.reload).to be_under_embargo
    end

  end
end
