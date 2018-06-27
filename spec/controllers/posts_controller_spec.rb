require 'rails_helper'

describe PostsController do
  describe 'GET #new' do
    it 'redirects to the root page if user is not signed in' do
      get :new

      expect(response).to redirect_to('/')
    end

    it 'shows post creation form if user is signed in' do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = create(:user, 
        provider: 'github', uid: '123', name: 'John Doe', image_url: 'url', profile_url: 'url'
      )
      post = instance_double(Post)
      allow(Post).to receive(:new).and_return(post)
      sign_in(user)

      get :new

      expect(assigns(:post)).to eq(post)
      expect(response).to render_template(:new)
      expect(response.code).to eq('200')
    end
  end

  describe 'GET #index' do
    it 'assigns posts' do
      post = instance_double(Post)
      another_post = instance_double(Post)
      decorated_post = double('decorated_post', created_at: '5 MAY 2018')
      another_decorated_post = double('decorated_post', created_at: '6 MAY 2018')
      allow(Post).to receive(:all).and_return([post, another_post])
      allow(PostDecorator).to receive(:decorate_collection).with(
        [post, another_post]
      ).and_return([decorated_post, another_decorated_post])

      get :index
      
      grouped_posts = {
        '5 MAY 2018' => [decorated_post],
        '6 MAY 2018' => [another_decorated_post]
      }
      expect(assigns(:posts)).to eq(grouped_posts)
      expect(response).to render_template(:index)
      expect(response.code).to eq('200')
      expect(Post).to have_received(:all).once
      expect(PostDecorator).to have_received(:decorate_collection).with(
        [post, another_post]
      ).once
    end
  end

  describe 'GET #show' do
    it 'assigns post' do
      post = instance_double(Post, id: 1)
      decorated_post = double('decorated_post')
      allow(Post).to receive(:find).with(post.id.to_s).and_return(post)
      allow(PostDecorator).to receive(:decorate).with(
        post
      ).and_return(decorated_post)

      get :show, params: { id: post.id }

      expect(assigns(:post)).to eq(decorated_post)
      expect(Post).to have_received(:find).with(post.id.to_s).once
      expect(response).to render_template(:show)
      expect(response.code).to eq('200')
      expect(PostDecorator).to have_received(:decorate).with(
        post
      ).once
    end
  end
end
