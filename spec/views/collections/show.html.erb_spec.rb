require 'spec_helper'

describe 'collections/show.html.erb' do
  let(:collection) { FactoryGirl.create(:collection) }
  let(:solr_response) { double(response: {"numFound"=>0}, grouped?:false, params:{}, total_pages:1) }

  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    allow_any_instance_of(Ability).to receive(:can?).and_return(true)
    assign(:collection, collection)
    assign(:response, solr_response)
    assign(:member_docs, [])
    controller.request.path_parameters[:id] = collection.pid
    assign(:events, [])
  end

  describe 'representative' do
    let(:generic_file) { FactoryGirl.create(:public_pdf) }
    before do
      allow(collection).to receive(:representative).and_return(generic_file.pid)
    end
    it "should display the representative work in media_display" do
      render
      expect(rendered).to have_selector('a[title$="Download the document"][href$="/downloads/sufia:fixture-pdf"]')
    end
  end

end
