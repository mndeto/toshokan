require "rails_helper"

describe DateNormalizationHelper do

  describe '#normalize_year' do
    it 'does not modify three- or four-digit years' do
      expect( helper.normalize_year(2006, 2, 2012) ).to eq 2006
    end

    it 'does not modify three- or four-digit years' do
      expect( helper.normalize_year(569, 2, 2012) ).to eq 569
    end

    it 'should convert one- or two-digit years to four-digit' do
      expect( helper.normalize_year(12, 2, 2012) ).to eq 2012
      expect( helper.normalize_year(20, 2, 2012) ).to eq 1920
    end

    it 'should convert one- or two-digit years correctly when near end of century' do
      expect( helper.normalize_year(12, 2, 2099) ).to eq 2012
      expect( helper.normalize_year(01, 2, 2099) ).to eq 2101
      expect( helper.normalize_year(01, 2, 2099) ).to eq 2101
    end
  end

  describe '#normalize_year_range' do
    it 'does not modify a valid range' do
      range = {'begin' => '2006', 'end' => '2012'}
      assert(range == normalize_year_range(range))
    end

    it 'does not modify open ranges' do
      range = {'begin' => '2006', 'end' => ''}
      expect( helper.normalize_year_range(range) ).to eq range

      range = {'begin' => '', 'end' => '2012'}
      expect( helper.normalize_year_range(range) ).to eq range

      range = {'begin' => '', 'end' => ''}
      expect( helper.normalize_year_range(range) ).to eq range
    end

    it 'should convert non-integer arguments into open ends' do
      range = {'begin' => 'a', 'end' => '2012'}
      expect( helper.normalize_year_range(range) ).to eq({'begin' => '', 'end' => '2012'})
    end

    it 'should convert one/two digit years to four-digit' do
      range = {'begin' => '06', 'end' => '12'}
      expect( helper.normalize_year_range(range) ).to eq({'begin' => '2006', 'end' => '2012'})
    end

    it 'should push end to begin if delta is negative' do
      range = {'begin' => '2012', 'end' => '2006'}
      expect( helper.normalize_year_range(range) ).to eq({'begin' => '2012', 'end' => '2012'})
    end
  end

end