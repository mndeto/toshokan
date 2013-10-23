require 'spec_helper'

describe User do
  subject do
    User.create
  end

  let(:another_user) {
    User.create
  }

  let(:document) {
    d = double("document")
    d.stub(:id).and_return("1")
    d
  }

  it "is valid" do
    subject.should be_valid
  end

  it "has roles" do
    sup_role = Role.find_by_code('SUP')
    adm_role = Role.find_by_code('ADM')
    subject.roles << sup_role << adm_role
    subject.roles.should include(sup_role, adm_role)
  end

  it "has own tags" do
    subject.tags.should eq []
  end

  it "has own taggings" do
    subject.taggings.should eq []
  end

  it "can tag a document" do
    subject.tag(document, 'a tag')
  end

  it "can list owned tags for document" do
    subject.tag(document, 'a tag')

    subject.tags.map(&:name).should eq ['a tag']
    subject.tags_for(document).map(&:name).should eq ['a tag']
  end

  it "can list owned tags for document id" do
    subject.tag(document, 'a tag')

    subject.tags.map(&:name).should eq ['a tag']
    subject.tags_for(document.id).map(&:name).should eq ['a tag']
  end

  it "can list owned tags for bookmark" do
    subject.tag(document, 'a tag')
    bookmark = subject.tags.find_by_name('a tag').bookmarks.first

    subject.tags.map(&:name).should eq ['a tag']
    subject.tags_for(bookmark).map(&:name).should eq ['a tag']
  end

  describe 'from Riyosha user data for DTU employee' do
    before(:each) do
      @user_data = {'id' => '12345',
                    'provider' => 'dtu',
                    'email' => 'mail@example.com',
                    'dtu' => {
                      'username'  => 'abcd',
                      'firstname' => 'Firstname',
                      'lastname'  => 'Lastname',
                      'user_type' => 'dtu_empl',
                      'matrikel_id' => '1234',
                    },
                    'address' => {
                      'line1'    => 'Address line 1',
                      'line2'    => 'Address line 2',
                      'line3'    => 'Address line 3',
                      'line4'    => 'Address line 4',
                      'line5'    => 'Address line 5',
                      'line6'    => 'Address line 6',
                      'zipcode'  => 'ZIP',
                      'cityname' => 'City',
                      'country'  => 'Country',
                   }}
      @provider = :cas
    end

    it "should be created correctly" do
      user = User.create_or_update_with_user_data(@provider, @user_data)
      user.persisted?.should be_true
      user.identifier.should eq @user_data['id']
      user.dtu?.should be_true
      user.employee?.should be_true
      user.student?.should be_false

      user.email.should eq 'mail@example.com'
      user.name.should eq 'Firstname Lastname'
      user.cwis.should eq '1234'

      user.address['line1'].should eq 'Address line 1'
      user.address['line2'].should eq 'Address line 2'
      user.address['line3'].should eq 'Address line 3'
      user.address['line4'].should eq 'Address line 4'
      user.address['line5'].should eq 'Address line 5'
      user.address['line6'].should eq 'Address line 6'
      user.address['zipcode'].should eq 'ZIP'
      user.address['cityname'].should eq 'City'
      user.address['country'].should eq 'Country'
    end

    it "should be updated correctly" do
      user = User.create_or_update_with_user_data(@provider, @user_data)
      user.email.should eq @user_data['email']

      @user_data['email'] = 'new_mail@example.com'
      updated_user = User.create_or_update_with_user_data(@provider, @user_data)
      updated_user.email.should eq @user_data['email']
      updated_user.id.should eq user.id
    end
  end

  describe "for anonymous user" do
    it "should be created correctly" do
      user = User.new
      user.persisted?.should be_false
      user.identifier.should be_nil
      user.dtu?.should be_false
      user.public?.should be_true

      user.email.should be_nil
      user.name.should eq 'Anonymous'

      user.address.should be_nil
    end
  end
end
