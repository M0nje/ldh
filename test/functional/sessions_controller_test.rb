require 'test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e)
                            fail e
                          end; end

class SessionsControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users, :people

  test 'sessions#index redirects to session#new' do
    get :index
    assert_redirected_to root_path
  end

  test 'session#show redirects to root page' do
    get :show
    assert_redirected_to root_path
  end

  test 'index_not_logged_in' do
    get :new
    assert_response :success

    User.destroy_all # remove all users
    assert_equal 0, User.count
    get :new
    assert_response :redirect
    assert_redirected_to signup_url
  end

  test 'title' do
    get :new
    assert_select 'title', text: 'Login', count: 1
  end

  test 'should log in with username' do
    post :create, params: { login: users(:quentin).login, password: 'test' }
    assert session[:user_id]
    assert_response :redirect
  end

  test 'should log in with email' do
    post :create, params: { login: users(:quentin).person.email, password: 'test' }
    assert session[:user_id]
    assert_response :redirect
  end

  # FIXME: check whether doing a redirect is a problem - this is a test generated by the restful_auth.. plugin, so is clearly there for a reason
  #  test 'should_fail_login_and_not_redirect' do
  #    post :create, :login => 'quentin', :password => 'bad password'
  #    assert_nil session[:user_id]
  #    assert_response :success
  #  end

  test 'should_logout' do
    login_as :quentin
    @request.env['HTTP_REFERER'] = '/data_files'
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  test 'should_remember_me' do
    post :create, params: { login: 'quentin', password: 'test', remember_me: 'on' }
    assert_not_nil @response.cookies['auth_token']
  end

  test 'should_not_remember_me' do
    post :create, params: { login: 'quentin', password: 'test', remember_me: 'off' }
    assert_nil @response.cookies['auth_token']
  end

  test 'should_delete_token_on_logout' do
    login_as :quentin
    @request.env['HTTP_REFERER'] = '/data_files'
    get :destroy
    assert_nil @response.cookies['auth_token']
  end

  test 'should_login_with_cookie' do
    users(:quentin).remember_me
    @request.cookies['auth_token'] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  test 'should_fail_expired_cookie_login' do
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies['auth_token'] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  test 'should_fail_cookie_login' do
    users(:quentin).remember_me
    @request.cookies['auth_token'] = 'invalid_auth_token'
    get :new
    assert !@controller.send(:logged_in?)
  end

  test 'non_activated_user_should_redirect_to_new_with_message' do
    user = FactoryBot.create(:brand_new_user, person: FactoryBot.create(:person))
    post :create, params: { login: user.login, password: user.password }
    assert !session[:user_id]
    assert_redirected_to login_path
    assert_not_nil flash[:error]
    assert flash[:error].include?('You still need to activate your account.')
  end

  test 'partly_registed_user_should_redirect_to_select_person' do
    user = FactoryBot.create(:brand_new_user)
    post :create, params: { login: user.login, password: user.password }
    assert session[:user_id]
    assert_equal user.id, session[:user_id]
    assert_not_nil flash.now[:notice]
    assert_redirected_to register_people_path
  end

  test 'should redirect to root after logging out from the search result page' do
    login_as :quentin
    @request.env['HTTP_REFERER'] = search_url
    get :destroy
    assert_redirected_to :root
  end

  test 'should redirect to back after logging out from the page excepting search result page' do
    login_as :quentin
    @request.env['HTTP_REFERER'] = data_files_url
    get :destroy
    assert_redirected_to data_files_url
  end

  test 'should redirect to root after logging in from the search result page' do
    @request.env['HTTP_REFERER'] = search_url
    post :create, params: { login: 'quentin', password: 'test' }
    assert_redirected_to :root
  end

  test 'should redirect to back after logging in from the page excepting search result page' do
    @request.env['HTTP_REFERER'] = data_files_url
    post :create, params: { login: 'quentin', password: 'test' }
    assert_redirected_to data_files_url
  end

  test 'should redirect to given path' do
    post :create, params: { login: 'quentin', password: 'test', called_from: { path: '/data_files' } }
    assert session[:user_id]
    assert_redirected_to data_files_path
  end

  test 'should not redirect to external url' do
    post :create, params: { login: 'quentin', password: 'test', called_from: { path: 'http://not.our.domain/data_files' } }

    assert session[:user_id]

    assert_not_includes @response.location, 'not.our.domain'
    assert_includes @response.location, Seek::Config.site_base_host
  end

  test 'should have only seek login' do
    with_config_value(:omniauth_enabled, false) do
      assert !Seek::Config.omniauth_enabled
      get :new
      assert_response :success
      assert_select 'title', text: 'Login', count: 1
      assert_select '#login-panel form', 1
    end
  end

  test 'should have omniauth login options' do
    with_config_value(:omniauth_enabled, true) do # This should be true by default in test env
      get :new
      assert_response :success
      assert_select '#login-panel form', 2
      assert_select '#ldap_login input[name="username"]', 1
      assert_select '#ldap_login input[name="password"]', 1
      assert_select '#elixir_aai_login a', 1
    end
  end

  test 'should only have enabled omniauth login options' do
    with_config_value(:omniauth_enabled, true) do
      with_config_value(:omniauth_ldap_enabled, false) do
        with_config_value(:omniauth_elixir_aai_enabled, true) do
          get :new
          assert_response :success
          assert_select '#login-panel form', 1
          assert_select '#ldap_login input[name="username"]', 0
          assert_select '#ldap_login input[name="password"]', 0
          assert_select '#elixir_aai_login a', 1
        end
      end
      with_config_value(:omniauth_ldap_enabled, true) do
        with_config_value(:omniauth_elixir_aai_enabled, false) do
          with_config_value(:omniauth_oidc_enabled, false) do
            get :new
            assert_response :success
            assert_select '#login-panel form', 2
            assert_select '#ldap_login input[name="username"]', 1
            assert_select '#ldap_login input[name="password"]', 1
            assert_select '#elixir_aai_login a', 0
            assert_select '#oidc_login a', 0
          end
        end
      end
      with_config_value(:omniauth_oidc_enabled, true) do
        get :new
        assert_response :success
        assert_select '#oidc_login a', 1
      end
    end
  end

  test 'should authenticate user with legacy encryption and update password' do
    sha1_user = FactoryBot.create(:sha1_pass_user)
    test_password = generate_user_password

    assert_equal User.sha1_encrypt(test_password, sha1_user.salt), sha1_user.crypted_password

    post :create, params: { login: sha1_user.login, password: test_password }
    assert session[:user_id]
    assert_response :redirect

    sha1_user.reload
    assert_equal User.sha256_encrypt(test_password, sha1_user.salt), sha1_user.crypted_password
  end

  test 'should show custom OIDC image if set' do
    with_config_value(:omniauth_oidc_enabled, true) do
      get :new

      assert_select '#oidc_login a', text: 'Sign in with SEEK Testing OIDC'
      assert_select '#oidc_login a img.icon'

      Seek::Config.omniauth_oidc_image = fixture_file_upload('file_picture.png', 'image/png')
      get :new

      assert_select '#oidc_login a img.icon', count: 0
      assert_select '#oidc_login a img[src=?]', Seek::Config.omniauth_oidc_image.public_asset_url
    end
  end

  protected

  def cookie_for(user)
    users(user).remember_token
  end
end
