require 'spec_helper'

describe 'generic_files/stats.html.erb', type: :view do
  describe 'usage statistics' do
    let(:generic_file) do
      stub_model(GenericFile, id: '123',
                              title: ['file1.txt'])
    end

    let(:no_stats) do
      allow_message_expectations_on_nil
      allow(FileUsage).to receive(:new)
      stub_model(FileUsage,
                 created: Date.parse('2014-01-01'),
                 total_pageviews: 0,
                 total_downloads: 0,
                 to_flot: []
                )
    end

    let(:stats) do
      allow(FileUsage).to receive(:new)
      stub_model(FileUsage,
                 created: Date.parse('2014-01-01'),
                 total_pageviews: 9,
                 total_downloads: 4,
                 to_flot: [[1_396_422_000_000, 2], [1_396_508_400_000, 3], [1_396_594_800_000, 4]]
                )
    end

    before do
      assign(:generic_file, generic_file)
      assign(:stats, no_stats)
    end

    context 'when no analytics results returned' do
      before do
        assign(:pageviews, 0)
      end

      it 'shows 0 visits' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_selector('div.alert-info', text: /0 views and 0 downloads since January 1, 2014/i, count: 1)
      end
    end

    context 'when results are returned' do
      before do
        assign(:stats, stats)
      end

      it 'shows visits' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_selector('div.alert-info', text: /9 views and 4 downloads since January 1, 2014/i, count: 1)
      end
    end
  end
end
