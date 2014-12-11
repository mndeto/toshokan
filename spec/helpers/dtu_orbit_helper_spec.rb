require 'rails_helper'

describe DtuOrbitHelper do

  describe '#dtu_orbit_backlink' do
    before do
      @document = SolrDocument.new
    end

    context 'when document has orbit source' do
      before do
        @document['source_ss'] = ['orbit']
      end
      
      context 'when document has orbit backlink' do
        before do
          @document['backlink_ss'] = ['http://orbit.dtu.dk/en/publications/id(a26904ce-6e2a-4726-a843-9b872e862de1).html']
        end

        it 'renders the DTU ORBIT backlink' do
          expect( dtu_orbit_backlink @document ).to have_css('.dtu-orbit-backlink')
        end
      end

      context 'when document only has non-orbit backlinks' do
        before do
          @document['backlink_ss'] = ['http://some-other-link.com/path']
        end

        it 'does not render a DTU ORBIT backlink' do
          expect( dtu_orbit_backlink @document ).to_not have_css('.dtu-orbit-backlink')
        end
      end

      context 'when document has no backlinks' do
        it 'does not render a DTU ORBIT backlink' do
          expect( dtu_orbit_backlink @document ).to_not have_css('.dtu-orbit-backlink')
        end
      end
    end

    context 'when document has no orbit source' do
      it 'does not render a DTU ORBIT backlink' do
        expect( dtu_orbit_backlink @document ).to_not have_css('.dtu-orbit-backlink')
      end
    end
  end

end