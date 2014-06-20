require 'spec_helper'

describe 'collections/edit.html.erb' do
  let(:collection) { FactoryGirl.create(:collection) }
  let(:solr_response) { double(response: {"numFound"=>0}, grouped?:false, params:{}, total_pages:1, total:0) }

  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    allow(view).to receive(:should_show_spellcheck_suggestions?).and_return(false)
    allow_any_instance_of(Ability).to receive(:can?).and_return(true)
    assign(:collection, collection)
    assign(:response, solr_response)
    assign(:member_docs, [])
    controller.request.path_parameters[:id] = collection.pid
    assign(:events, [])
  end

  describe 'representative' do
    describe "when collection has members" do
      let(:generic_file) { FactoryGirl.create(:public_pdf) }
      before do
        collection.members << generic_file
        collection.save
        allow(collection).to receive(:representative).and_return(generic_file.pid)
      end
      it "should display the representative work in media_display" do
        render
        expect(rendered).to have_selector('a[title$="Download the document"][href$="/downloads/sufia:fixture-pdf"]')
      end
      it "should display field for specifying the representative" do
        render
        expect(rendered).to have_content("Representative File")
        expect(rendered).to have_select("collection_representative", with_options:["- Select one -",generic_file.title.first])
      end
    end
    describe "when collection does not have members" do
      it "should not display field for specifying the representative" do
        render
        expect(rendered).not_to have_content("Representative File")
      end
    end
  end

end
