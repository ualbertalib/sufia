require 'spec_helper'

describe 'collection', type: :feature do
  def create_collection(title, description)
    visit '/dashboard'
    first('#hydra-collection-add').click
    expect(page).to have_content 'Create New Collection'

    # Creator is a multi-value field, so it should have button to add more fields
    expect(page).to have_selector "div.collection_creator .input-append button.add"

    # Title is a single-value field, so it should not have the adder button
    expect(page).to_not have_selector "div.collection_title .input-append button.add"

    fill_in('Title', with: title)
    fill_in('Abstract or Summary', with: description)
    click_button("Create Collection")
    expect(page).to have_content 'Items in this Collection'
    expect(page).to have_content title
    expect(page).to have_content description
  end

  let(:title1) { "Test Collection 1" }
  let(:description1) { "Description for collection 1 we are testing." }
  let(:title2) { "Test Collection 2" }
  let(:description2) { "Description for collection 2 we are testing." }

  let(:collection1) do
    Collection.create(title: title1, description: description1,
                      members: []) { |c| c.apply_depositor_metadata(user.user_key) }
  end
  let(:collection2) do
    Collection.create(title: title2, description: description2,
                      members: []) { |c| c.apply_depositor_metadata(user.user_key) }
  end

  let(:user) { FactoryGirl.create(:user) }

  let(:gfs) do
    (0..1).map do |x|
      GenericFile.create(title: ["title #{x}"]) do |f|
        f.apply_depositor_metadata(user.user_key)
      end
    end
  end

  let(:gf1) { gfs[0] }
  let(:gf2) { gfs[1] }

  describe 'create collection' do
    let!(:gf1) { gfs[0] }
    let!(:gf2) { gfs[1] }

    before do
      sign_in user
      create_collection(title2, description2)
    end

    it "creates collection from the dashboard and include files", js: true do
      visit '/dashboard/files'
      first('input#check_all').click
      click_button "Add to Collection" # opens the modal
      # since there is only one collection, it's not necessary to choose a radio button
      click_button "Update Collection"
      expect(page).to have_content "Items in this Collection"
      # There are two rows in the table per document (one for the general info, one for the details)
      # Make sure we have at least 2 documents
      expect(page).to have_selector "table.table-zebra-striped tr#document_#{gf1.id}"
      expect(page).to have_selector "table.table-zebra-striped tr#document_#{gf2.id}"
    end
  end

  describe 'delete collection' do
    let!(:collection) do
      Collection.create(title: 'collection title', description: 'collection description') do |c|
        c.apply_depositor_metadata(user.user_key)
      end
    end
    before do
      sign_in user
      visit '/dashboard/collections'
    end

    it "deletes a collection" do
      expect(page).to have_content(collection.title)
      within('#document_' + collection.id) do
        first('button.dropdown-toggle').click
        first(".itemtrash").click
      end
      expect(page).not_to have_content(collection.title)
    end
  end

  describe 'show collection' do
    let!(:collection) do
      Collection.create(title: 'collection title', description: 'collection description',
                        members: [gf1, gf2]) do |c|
        c.apply_depositor_metadata(user.user_key)
      end
    end
    before do
      sign_in user
      visit '/dashboard/collections'
    end

    it "shows a collection with a listing of Descriptive Metadata and catalog-style search results" do
      expect(page).to have_content(collection.title)
      within('#document_' + collection.id) do
        click_link("Display all details of collection title")
      end
      expect(page).to have_content(collection.title)
      expect(page).to have_content(collection.description)
      # Should not show title and description a second time
      expect(page).to_not have_css('.metadata-collections', text: collection.title)
      expect(page).to_not have_css('.metadata-collections', text: collection.description)
      # Should not have Collection Descriptive metadata table
      expect(page).to have_content("Descriptions")
      # Should have search results / contents listing
      expect(page).to have_content(gf1.title.first)
      expect(page).to have_content(gf2.title.first)
      expect(page).to_not have_css(".pager")

      click_link "Gallery"
      expect(page).to have_content(gf1.title.first)
      expect(page).to have_content(gf2.title.first)
    end

    it "hides collection descriptive metadata when searching a collection" do
      # URL: /dashboard/collections
      expect(page).to have_content(collection.title)
      within("#document_#{collection.id}") do
        click_link("Display all details of collection title")
      end
      # URL: /collections/collection-id
      expect(page).to have_content(collection.title)
      expect(page).to have_content(collection.description)
      expect(page).to have_content(gf1.title.first)
      expect(page).to have_content(gf2.title.first)
      fill_in('collection_search', with: gf1.title.first)
      click_button('collection_submit')
      # Should not have Collection metadata table (only title and description)
      expect(page).to_not have_content("Total Items")
      expect(page).to have_content(collection.title)
      expect(page).to have_content(collection.description)
      # Should have search results / contents listing
      expect(page).to have_content("Search Results")
      expect(page).to have_content(gf1.title.first)
      expect(page).to_not have_content(gf2.title.first)
    end
  end

  describe 'collection sorting' do
    before do
      collection1 # create the collections by referencing them
      sleep(1) # make sure the timestamps aren't equal
      collection2
      sleep(1)
      collection1.title += 'changed'
      collection1.save
      # collection 1 is now earlier when sorting by create date but later
      # when sorting by modified date

      sign_in user
      visit '/dashboard/collections'
    end

    it "has creation date for collections" do
      expect(page).to have_content(collection1.create_date.to_date.to_formatted_s(:standard))
    end

    it "allows changing sort order" do
      find(:xpath, "//select[@id='sort']/option[contains(., 'date modified')][contains(@value, 'asc')]") \
        .select_option
      click_button('Refresh')
      expect(page).to have_css("#document_#{collection1.id}")
      expect(page).to have_css("#document_#{collection2.id}")
      expect(page.body.index("id=\"document_#{collection1.id}")).to be > page.body.index("id=\"document_#{collection2.id}")

      find(:xpath, "//select[@id='sort']/option[contains(., 'date modified')][contains(@value, 'desc')]") \
        .select_option
      click_button('Refresh')
      expect(page).to have_css("#document_#{collection1.id}")
      expect(page).to have_css("#document_#{collection2.id}")
      expect(page.body.index("id=\"document_#{collection1.id}")).to be < page.body.index("id=\"document_#{collection2.id}")
    end
  end

  describe 'add files to collection' do
    let!(:gf1) { gfs[0] }
    let!(:gf2) { gfs[1] }

    before do
      collection1 # create collections by referencing them
      collection2
      sign_in user
    end

    it "preselects the collection we are adding files to" do
      visit "/collections/#{collection1.id}"
      click_link 'Add files'
      first('input#check_all').click
      click_button "Add to Collection"
      expect(page).to have_css("input#id_#{collection1.id}[checked='checked']")
      expect(page).not_to have_css("input#id_#{collection2.id}[checked='checked']")

      visit "/collections/#{collection2.id}"
      click_link 'Add files'
      first('input#check_all').click
      click_button "Add to Collection"
      expect(page).not_to have_css("input#id_#{collection1.id}[checked='checked']")
      expect(page).to have_css("input#id_#{collection2.id}[checked='checked']")
    end
  end

  describe 'upload files to collection' do
    let(:upload_to_collection) { true }
    let!(:gf1) { gfs[0] }
    let!(:gf2) { gfs[1] }

    before do
      Sufia.config.upload_to_collection = upload_to_collection
      collection1 # create collections by referencing them
      collection2
      sign_in user
    end

    it "preselects the collection we are uploading files to" do
      visit "/collections/#{collection1.id}"
      click_link 'Upload files'
      expect(page).to have_select('collection', selected: title1)
    end
  end

  describe 'edit collection' do
    let!(:collection) do
      Collection.create(title: 'collection title', description: 'collection description',
                        members: [gf1, gf2]) { |c| c.apply_depositor_metadata(user.user_key) }
    end

    before do
      sign_in user
      visit '/dashboard/collections'
    end

    it "edits and update collection metadata" do
      # URL: /dashboard/collections
      expect(page).to have_content(collection.title)
      within("#document_#{collection.id}") do
        find('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      # URL: /collections/collection-id/edit
      expect(page).to have_field('collection_title', with: collection.title)
      expect(page).to have_field('collection_description', with: collection.description)
      new_title = "Altered Title"
      new_description = "Completely new Description text."
      creators = ["Dorje Trollo", "Vajrayogini"]
      fill_in('Title', with: new_title)
      fill_in('Abstract or Summary', with: new_description)
      fill_in('Creator', with: creators.first)
      within('.primary-actions') do
        click_button('Update Collection')
      end
      # URL: /collections/collection-id
      header = find('header')
      expect(header).to_not have_content(collection.title)
      expect(header).to_not have_content(collection.description)
      expect(header).to have_content(new_title)
      expect(header).to have_content(new_description)
      expect(page).to have_content(creators.first)
    end

    it "removes a file from a collection" do
      expect(page).to have_content(collection.title)
      within("#document_#{collection.id}") do
        first('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      expect(page).to have_field('collection_title', with: collection.title)
      expect(page).to have_field('collection_description', with: collection.description)
      expect(page).to have_content(gf1.title.first)
      expect(page).to have_content(gf2.title.first)
      within("#document_#{gf1.id}") do
        first('button.dropdown-toggle').click
        click_button('Remove from Collection')
      end
      expect(page).to have_content(collection.title)
      expect(page).to have_content(collection.description)
      expect(page).not_to have_content(gf1.title.first)
      expect(page).to have_content(gf2.title.first)
    end

    it "removes all files from a collection", js: true do
      expect(page).to have_content(collection.title)
      within('#document_' + collection.id) do
        first('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      expect(page).to have_field('collection_title', with: collection.title)
      expect(page).to have_field('collection_description', with: collection.description)
      expect(page).to have_content(gf1.title.first)
      expect(page).to have_content(gf2.title.first)
      first('input#check_all').click
      click_button('Remove From Collection')
      expect(page).to have_content(collection.title)
      expect(page).to have_content(collection.description)
      expect(page).not_to have_content(gf1.title.first)
      expect(page).not_to have_content(gf2.title.first)
    end
  end

  describe 'show pages of a collection' do
    let(:gfs) do
      (0..12).map do |x|
        GenericFile.create(title: ["title #{x}"]) do |f|
          f.apply_depositor_metadata(user.user_key)
        end
      end
    end

    before { sign_in user }

    let!(:collection) do
      Collection.create(title: 'collection title', description: 'collection description',
                        members: gfs) { |c| c.apply_depositor_metadata(user.user_key) }
    end

    it "shows a collection with a listing of Descriptive Metadata and catalog-style search results" do
      visit '/dashboard/collections'
      expect(page).to have_content(collection.title)
      within('#document_' + collection.id) do
        click_link("Display all details of collection title")
      end
      expect(page).to have_css(".pager")
    end
  end
end
