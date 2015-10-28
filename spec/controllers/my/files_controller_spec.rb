require 'spec_helper'

describe My::FilesController, type: :controller do
  let(:my_collection) do
    Collection.create(title: 'test collection') do |c|
      c.apply_depositor_metadata(user.user_key)
    end
  end

  let(:other_collection) do
    Collection.create(title: 'other test collection') do |c|
      c.apply_depositor_metadata(another_user.user_key)
    end
  end

  let(:shared_file) do
    FactoryGirl.build(:generic_file).tap do |r|
      r.apply_depositor_metadata FactoryGirl.create(:user)
      r.edit_users += [user.user_key]
      r.save!
    end
  end

  let(:user) { FactoryGirl.find_or_create(:archivist) }

  let(:another_user) { FactoryGirl.find_or_create(:jill) }

  before do
    sign_in user
    @my_file = FactoryGirl.create(:generic_file, depositor: user)
    @my_collection = my_collection
    @other_collection = other_collection
    @shared_file = shared_file
    @unrelated_file = FactoryGirl.create(:generic_file, depositor: FactoryGirl.create(:user))
    @wrong_type = Batch.create
  end

  it "responds with success" do
    get :index
    expect(response).to be_successful
  end

  it "paginates" do
    FactoryGirl.create(:generic_file)
    FactoryGirl.create(:generic_file)
    get :index, per_page: 2
    expect(assigns[:document_list].length).to eq 2
    get :index, per_page: 2, page: 2
    expect(assigns[:document_list].length).to be >= 1
  end

  it "shows the correct files" do
    get :index
    # shows documents I deposited
    expect(assigns[:document_list].map(&:id)).to include(@my_file.id)
    # doesn't show collections
    expect(assigns[:document_list].map(&:id)).to_not include(@my_collection.id)
    # doesn't show shared files
    expect(assigns[:document_list].map(&:id)).to_not include(@shared_file.id)
    # doesn't show other users' files
    expect(assigns[:document_list].map(&:id)).to_not include(@unrelated_file.id)
    # doesn't show non-generic files
    expect(assigns[:document_list].map(&:id)).to_not include(@wrong_type.id)
  end

  it "has the correct collections" do
    get :index
    expect(assigns[:user_collections].map(&:id)).to include(@my_collection.id)
    expect(assigns[:user_collections].map(&:id)).to_not include(@other_collection.id)
  end

  describe "batch processing" do
    include Sufia::Messages
    let(:batch_id) { "batch_id" }
    let(:batch_id2) { "batch_id2" }
    let(:batch) { double }

    before do
      allow(batch).to receive(:id).and_return(batch_id)
      User.batchuser.send_message(user, single_success(batch_id, batch), success_subject, false)
      User.batchuser.send_message(user, multiple_success(batch_id2, [batch]), success_subject, false)
      get :index
    end
    it "gets batches that are complete" do
      expect(assigns(:batches).count).to eq(2)
      expect(assigns(:batches)).to include("ss-" + batch_id)
      expect(assigns(:batches)).to include("ss-" + batch_id2)
    end
  end

  it "sets add_files_to_collection when provided in params" do
    get :index, add_files_to_collection: '12345'
    expect(assigns(:add_files_to_collection)).to eql('12345')
  end
end
