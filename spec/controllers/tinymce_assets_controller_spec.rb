require 'spec_helper'

describe TinymceAssetsController, type: :controller do
  let(:file) { fixture_file_upload('/world.png', 'image/png') }

  context "when logged in" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    context "as a user who can upload" do
      before { expect(controller).to receive(:authorize!).with(:create, TinymceAsset).and_return(true) }

      it "uploads the file" do
        expect do
          post :create, file: file
          expect(response).to be_successful
        end.to change { TinymceAsset.count }.by(1)

        json = JSON.parse(response.body)
        expect(json).to eq("image" => { "url" => "/uploads/tinymce_asset/file/1/world.png" })
      end
    end

    context "as a user who can't upload" do
      it "redirects to root path" do
        post :create, file: file
        expect(response).to redirect_to root_path
      end
    end
  end

  context "when not logged in" do
    it "redirects to root path" do
      post :create, file: file
      expect(response).to redirect_to main_app.new_user_session_path
    end
  end
end
