# -*- encoding: utf-8 -*-
require 'rails_helper'
require 'cancan/matchers'

describe PagesController do
  describe '#searchbox_styled' do
    it 'does not send X-Frame-Options header' do
      get :searchbox_styled
      expect(response.headers).not_to have_key('X-Frame-Options')
    end
  end

  describe '#authentication_required' do
    let(:params) {
      { :url => root_url }
    }

    context 'when logged in' do
      it 'should redirect directly to the giver url' do
        login
        get :authentication_required, params
        expect(response).to redirect_to params[:url]
      end
    end

    context 'when not logged in' do
      it 'should render the template and return 403 Forbidden' do
        get :authentication_required, params
        expect(response).to be_forbidden
        expect(response).to render_template 'pages/authentication_required'
      end
    end
  end

end
