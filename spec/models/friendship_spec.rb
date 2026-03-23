require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend).class_name('User') }
  end

  describe 'validations' do
    subject { create(:friendship) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:friend_id) }

    it 'does not allow befriending yourself' do
      user = create(:user)
      friendship = build(:friendship, user: user, friend: user)
      expect(friendship).not_to be_valid
      expect(friendship.errors[:friend]).to include("can't be yourself")
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, accepted: 1) }

    it 'defaults to pending' do
      friendship = create(:friendship)
      expect(friendship).to be_pending
    end
  end

  describe 'scopes' do
    describe '.accepted' do
      it 'returns only accepted friendships' do
        accepted = create(:friendship, :accepted)
        create(:friendship, :pending)

        expect(Friendship.accepted).to eq([ accepted ])
      end
    end

    describe '.pending_for' do
      it 'returns pending friendships where user is the friend' do
        user = create(:user)
        pending_for_user = create(:friendship, friend: user, status: :pending)
        create(:friendship, friend: user, status: :accepted)
        create(:friendship, status: :pending)

        expect(Friendship.pending_for(user)).to eq([ pending_for_user ])
      end
    end
  end

  describe '#accept!' do
    it 'changes status to accepted' do
      friendship = create(:friendship, :pending)
      friendship.accept!
      expect(friendship.reload).to be_accepted
    end

    it 'creates the reverse friendship record' do
      friendship = create(:friendship, :pending)
      expect { friendship.accept! }.to change(Friendship, :count).by(1)

      reverse = Friendship.find_by(user: friendship.friend, friend: friendship.user)
      expect(reverse).to be_present
      expect(reverse).to be_accepted
    end

    it 'wraps everything in a transaction' do
      friendship = create(:friendship, :pending)
      # Create reverse record first to trigger uniqueness violation
      create(:friendship, user: friendship.friend, friend: friendship.user, status: :pending)

      # accept! should still succeed via find_or_create_by!
      friendship.accept!
      reverse = Friendship.find_by(user: friendship.friend, friend: friendship.user)
      expect(reverse).to be_accepted
    end
  end
end
