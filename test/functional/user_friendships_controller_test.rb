require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase

    context "#index" do
        context "when not logged in" do
            should "redirect to login page" do
                get :index
                assert_response :redirect
                end
            end

            context "when logged in" do
                setup do
                    @friendship1 = create(:pending_user_friendship, user: users(:Keontez), friend: create(:user, first_name: 'Pending', last_name: 'Friend'))
                    @friendship2 = create(:accepted_user_friendship, user: users(:Keontez), friend: create(:user, first_name: 'Active', last_name: 'Friend'))
                    
                    sign_in users(:Keontez)
                    get :index
                    
                end

                should "get the index page without error" do
                    assert_response :success
            end

            should "assigns user_friendships" do
                assert assigns(:user_friendships)
        end

        should "display friend's name" do
            assert_match /Pending/, response.body
            assert_match /Active/, response.body
        end

        should "display pending information on a pending friendship" do
        assert_select "#user_friendship_#{@friendship1.id}" do
          assert_select "em", "Friendship is pending."
        end
      end

      should "display date information on a accepted friendship" do
        assert_select "#user_friendship_#{@friendship2.id}" do
          assert_select "em", "Friendship started #{@friendship2.updated_at}."
        end
      end


	context "#new" do
		context "when not logged in" do
			should "redirect to login page" do
				get :new
				assert_response :redirect
			end
		end

		context "when logged in" do
			setup do
				sign_in users(:Keontez)
		end

		should "get new and retun success" do
			get :new
			assert_response :success
		end

		should "should set a flash error if the friend_id params is missing" do
			get :new, {}
			assert_equal "Friend required", flash[:error]
		end

		should "display the friend's name" do
			get :new, friend_id: users(:Mevo04)
			assert_match /#{users(:Mevo04).full_name}/, response.body
		end

		should "assign a new user friendship" do
			get :new, friend_id: users(:Mevo04)
			assert assigns(:user_friendship)
		end

		should "assign a new user friendship to the correct friend" do
			get :new, friend_id: users(:Mevo04)
			assert_equal users(:Mevo04), assigns(:user_friendship).friend
		end

		should "assign a new user friendship to the currently logged in user" do
			get :new, friend_id: users(:Mevo04)
			assert_equal users(:Keontez), assigns(:user_friendship).user
		end

		should "returns a 404 status if no friend is found" do
			get :new, friend_id: 'invalid'
			assert_response :not_found
		end

		should "ask if you really wanna be friends" do
		get :new, friend_id: users(:Mevo04)
		assert_match /Do you really want to friend #{users(:Mevo04).full_name}?/, response.body
		end
	  end
    end

    context "#create" do
    	context "when not logged in" do
    		should "redirect to the login page" do
    			get :new
    			assert_response :redirect
    			assert_redirected_to login_path
    		end
    	end

    	context "when logged in" do
    		setup do
    			sign_in users(:Keontez)
    		end

    	context "with no friend_id" do
    		setup do
    			post :create
    	end

    	should "set the flash error message" do
    		assert !flash[:error].empty?
    		end

    		should "redirect to root path if friend isn't found" do
    			assert_redirected_to root_path
    		end
    	end

    	context "with a valid friend_id" do
    		setup do
    			post :create, user_friendship: {friend_id: users(:Mevo04)}
    		end

    		should "assign a friend object" do
    		assert assigns(:friend)
    		assert_equal users(:Mevo04), assigns(:friend)
    		end

    		should "assign a user_friendship object" do
    			assert assigns(:user_friendship)
    			assert_equal users(:Keontez), assigns(:user_friendship).user
    			assert_equal users(:Mevo04), assigns(:user_friendship).friend
    		end

    		should "create a friendship" do
    			assert users(:Keontez).pending_friends.include?(users(:Mevo04))
    		end

    		should "redirect to the profile page of the friend" do
    			assert_response :redirect
    			assert_redirected_to profile_path(users(:Mevo04))
    		end

    		should "set the flash success message" do
    			assert flash[:success]
    			assert_equal "You are now friends with #{users(:Mevo04).full_name}", flash[:success]
    		end
    		end
    end
  end
end
end
end