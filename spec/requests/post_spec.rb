require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts' do 

    it 'should return OK' do 
      get '/posts'
      payload = JSON.parse(response.body)
      expect( payload ).to be_empty
      expect( response ).to have_http_status(200)
    end

    describe 'Search' do 
      let!(:hello_world) { create(:published_post, title: 'Hello world') }
      let!(:hello_cosmos) { create(:published_post, title: 'Hello cosmos') }
      let!(:rails_course) { create(:published_post, title: 'Rails course') }

      it 'should filter posts by title' do 
        get "/posts?search=Hello"
        payload = JSON.parse(response.body)
        expect( payload ).to_not be_empty
        expect( payload.size ).to eq(2)
        expect( payload.map { |p| p['id'] }.sort ).to eq([hello_world.id, hello_cosmos.id].sort)
      end
    end

  end

  describe 'with data in DB' do 
    let!(:posts) { create_list(:post, 10, published: true) }
    it 'should return all published posts' do 
      get '/posts'
      payload = JSON.parse(response.body)
      expect( payload.size ).to eq(posts.size)
      expect( response ).to have_http_status(200)
    end
  end
  
  describe 'GET /posts/{id}' do 
    let!(:post) { create(:post) }

    it 'should return a post' do
      get "/posts/#{post.id}" 
      payload = JSON.parse(response.body)
      expect( payload ).to_not be_empty
      expect( payload['id'] ).to eq(post['id'])
      expect( payload['title'] ).to eq(post.title)
      expect( payload['content'] ).to eq(post.content)
      expect( payload['published'] ).to eq(post.published)
      expect( payload['author']['name'] ).to eq(post.user.name)
      expect( payload['author']['email'] ).to eq(post.user.email)
      expect( payload['author']['id'] ).to eq(post.user.id)
      expect( response ).to have_http_status(200)
    end
  end

  describe 'POST /posts' do 
    let!(:user) { create(:user) }

    it 'should create a post' do 
      req_payload = {
        post: {
          title: 'title',
          content: 'content',
          published: false,
          user_id: user.id
        }
      }  
      # POST HTTP
      post '/posts', params: req_payload

      payload = JSON.parse(response.body)
      expect( payload ).to_not be_empty
      expect( payload['id'] ).to_not be_nil
      expect( response ).to have_http_status(:created)
    end

    it 'should return an error message on invalid post' do 
      req_payload = {
        post: {
          content: 'content',
          published: false,
          user_id: user.id
        }
      }  
      # POST HTTP
      post '/posts', params: req_payload

      payload = JSON.parse(response.body)
      expect( payload ).to_not be_empty
      expect( payload['error'] ).to_not be_empty
      expect( response ).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /posts/{id}' do
    let!(:post) { create(:post) }

    it 'should update a post' do
      req_payload = {
        post: {
          title: 'title edited',
          content: 'content 2',
          published: true,
        }
      }

      put "/posts/#{post.id}", params: req_payload
      payload = JSON.parse(response.body)
      expect( payload ).to_not be_empty
      expect( payload['id'] ).to eq(post.id)
      expect( response ).to have_http_status(:ok)
    end

    it 'should return an error message on invalid post' do 
      req_payload = {
        post: {
          title: nil,
          content: nil,
          published: false,
        }
      }  
      put "/posts/#{post.id}", params: req_payload
      payload = JSON.parse(response.body)
      expect( payload ).to_not be_empty
      expect( payload['error'] ).to_not be_empty
      expect( response ).to have_http_status(:unprocessable_entity)    
    end
  end

end