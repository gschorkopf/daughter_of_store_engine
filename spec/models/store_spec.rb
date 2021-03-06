require 'spec_helper'

describe Store do
  subject do
    Store.new(
      name: 'Petals, Purses and Pastries',
      path: 'petals-purses-and-pastries')
  end

  it 'requires a name' do
    expect { subject.name = '' }.to change{ subject.valid? }.to(false)
  end

  it 'requires a unique name' do
    subject.save
    store = FactoryGirl.build(:store, name: 'Petals, Purses and Pastries')
    expect(store).to_not be_valid
  end

  it 'requires a path' do
    expect { subject.path = '' }.to change{ subject.valid? }.to(false)
  end

  it 'requires a unique path' do
    subject.save
    store = FactoryGirl.build(:store, path: 'petals-purses-and-pastries')
    expect(store).to_not be_valid
  end

  it 'requires a status' do
    expect { subject.status = '' }.to change{ subject.valid? }.to(false)
  end

  it 'requires a status within the valid set' do
    expect { subject.status = 'abc' }.to change{ subject.valid? }.to(false)
  end

  it 'parameterizes path before validation' do
    subject.path = "Oh yeah"
    subject.save
    expect(subject.path).to eq('oh-yeah')
  end

  context 'is_admin?' do
    it 'returns true when user is uber' do
      user = FactoryGirl.create(:user)
      user.uber_up
      expect(subject.is_admin?(user)).to eq true
    end

    it 'returns true when user is admin for store' do
      user = FactoryGirl.create(:user)
      subject.save
      Role.promote(user, subject, 'admin')
      expect(subject.is_admin?(user)).to eq true
    end

    it 'returns false when user is admin for another store' do
      user = FactoryGirl.create(:user)
      store = FactoryGirl.create(:store)
      Role.promote(user, store, 'admin')
      expect(subject.is_admin?(user)).to eq false
    end
  end

  it 'to_param' do
    expect(subject.to_param).to eq subject.path
  end

  it 'pending?' do
    expect(subject.pending?).to eq true
  end

  describe 'toggle_online_status' do
    it 'toggles online to offline' do
      subject.status = 'online'
      subject.toggle_online_status(:uber)
      expect(subject.status).to eq 'offline'
    end

    it 'toggles offline to online' do
      subject.status = 'offline'
      subject.toggle_online_status(:uber)
      expect(subject.status).to eq 'online'
    end

    it 'does not change status where not offline or online' do
      subject.toggle_online_status(:uber)
      expect(subject.status).to eq 'pending'
    end
  end

  describe '.popular' do
    it 'delegates to LocalStore.popular' do
      subject.save
      LocalStore.stub(:popular_store).and_return(subject.id)
      popular = Store.popular
      expect(popular).to eq subject
    end

    context "a user visits a store page for the first time in a session" do

      before do
        subject.save
        # user_ip = "127.0.0.1"
      end

      it "increases that store's popularity" do
      end
    end

    context "a user visits a store page for a second (or more) time in a session" do

      it "does not increase that store's  popularity" do
      end
    end
  end

  describe '.recent' do
    it 'select the most recently added store' do
      s1 = FactoryGirl.create(:store)
      s2 = FactoryGirl.create(:store)
      recent = Store.recent
      expect(recent).to eq s2
    end
  end

  describe '#orders' do
    # TODO: Frank why is this failing? It's the correct order with a different ID...
    it 'returns all orders that have at least one of their products in it' do
      subject.save
      product = FactoryGirl.create(:product, store: subject)
      order = FactoryGirl.create(:order, user_id: 1)
      FactoryGirl.create(:order_item, product: product, order: order)
      expect(subject.orders).to eq [order]
    end
  end
end
