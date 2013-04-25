require 'spec_helper'

describe HomepageController do
  describe 'GET #index' do
    it 'renders index' do
      get :show
      expect(response).to render_template(:show)
    end

    it 'assigns featured products' do
      Product.stub(:featured).and_return('I was called!')
      get :show
      expect(assigns(:featured_products)).to eq 'I was called!'
    end

    it 'assigns featured store' do
      Store.stub(:featured).and_return('I am the featured store!')
      get :show
      expect(assigns(:featured_store)).to eq 'I am the featured store!'
    end

    it 'assigns recent store' do
      Store.stub(:recent).and_return('I am recent')
      get :show
      expect(assigns(:recent_store)).to eq 'I am recent'
    end

    it 'assigns recently listed products' do
      Product.stub(:recent).and_return('recently listed')
      get :show
      expect(assigns(:recently_listed)).to eq 'recently listed'
    end
  end
end