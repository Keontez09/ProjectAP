require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
	should belong_to(:user)
	should belong_to(:friend)

	test "that creating a friendship works without raising an exception" do
	 assert_nothing_raised do
		UserFriendship.create user: users(:Keontez), friend: users(:Mike)
	end
	end

	test "that creating a friendship based on user id and friend id works" do
		UserFriendship.create user_id: users(:Keontez).id, friend_id: users(:Mevo04).id
		assert users(:Keontez).pending_friends.include?(users(:Mevo04))
	end

	context "a new instance" do
		setup do
			@user_friendship = UserFriendship.new user: users(:Keontez), friend: users(:Mevo04)
end

	should "have a pending state" do
		assert_equal 'pending', @user_friendship.state
	end
end

	context "send_request_email" do
		setup do
			@user_friendship = UserFriendship.create user: users(:Keontez), friend: users(:Mevo04)
	end

	should "send an email" do
		assert_difference 'ActionMailer::Base.deliveries.size', 1 do
			@user_friendship.send_request_email
		end
	
end

	context "#accept!" do
	setup do
		@user_friendship = UserFriendship.create user: users(:Keontez), friend: users(:Mevo04)
	end

	should "set the state to accepted" do
		@user_friendship.accept!
		assert_equal "accepted", @user_friendship.state
	end

	should "send an acceptance email" do
		assert_difference 'ActionMailer::Base.deliveries.size', 1 do
			@user_friendship.accept!
		end
	end

	should "include the friend in the list of friends" do
		@user_friendship.accept!
		users(:Keontez).friends.reload
		assert users(:Keontez).friends.include?(users(:Mevo04))
	end
end

	context ".request" do
		should "create two user friendships" do
			assert_difference 'UserFriendship.count', 2 do
				UserFriendship.request(users(:Keontez), users(:Mevo04))
			end
		end

		should "send an friend request email" do
		assert_difference 'ActionMailer::Base.deliveries.size', 1 do
			UserFriendship.request(users(:Keontez), users(:Mevo04))
		end
	end
	end
end
end