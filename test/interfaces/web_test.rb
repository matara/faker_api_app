require 'test_helper'
require 'rack_test_helper'

describe app do

  let(:web_host) { 'test.domain.com' }

  before do
    env('HTTP_HOST', web_host)
  end

  describe 'main page' do
    before do
      get '/'
    end
    it 'render main page' do
      expect(last_response.status).must_equal 200
    end

    it 'render text' do
      expect(last_response.body).must_equal 'API interface for https:://github.com/stympy/faker gem'
    end
  end

  describe '#faker endpoint' do
    describe 'when no params present' do
      it 'Address.state' do
        get '/faker/address/state'
        assert_includes Faker::Base.fetch_all('address.state'), response_json['data'].first
        expect_faker_response('Faker::Address', 'state')
      end

      it 'return Address.state' do
        get '/faker/internet/domain_suffix'
        assert_includes Faker::Base.fetch_all('internet.domain_suffix'), response_json['data'].first
        expect_faker_response('Faker::Internet', 'domain_suffix')
      end

      after do
        expect(response_json['data'].size).must_equal(1)
      end
    end

    describe 'when count params present' do
      before do
        @count = rand(2..5)
      end

      it 'return array of data' do
        get '/faker/food/ingredient?count=' + @count.to_s
        indredients = Faker::Base.fetch_all('food.ingredients')
        response_json['data'].each do |indredient|
          assert_includes indredients, indredient
        end
        expect_faker_response('Faker::Food', 'ingredient')
      end

      after do
        expect(response_json['data'].size).must_equal(@count)
        expect(response_json['data'].uniq.size).must_equal(@count)
      end
    end

    describe 'when undefined words' do
      it 'with undefined module' do
        get '/faker/blabla/ingredient'
      end

      it 'with undefined method' do
        get '/faker/Food/blabla'
      end

      after do
        expect(last_response.status).must_equal 200
        expect(last_response.headers['Content-Type']).must_equal 'application/json'
        expect(response_json['data']).must_equal([])
        expect(response_json['module']).must_equal('')
        expect(response_json['method']).must_equal('')
      end
    end

    it 'when module plural' do
      get '/faker/friend/character'
      expect_faker_response('Faker::Friends', 'character', skip_data_empty: true)
      get '/faker/friend/characters'
      expect_faker_response('Faker::Friends', 'character', skip_data_empty: true)
      get '/faker/friends/character'
      expect_faker_response('Faker::Friends', 'character', skip_data_empty: true)
      get '/faker/friends/characters'
      expect_faker_response('Faker::Friends', 'character', skip_data_empty: true)
    end

    it 'when module singular' do
      get '/faker/food/ingredient'
      expect_faker_response('Faker::Food', 'ingredient', skip_data_empty: true)
      get '/faker/food/ingredients'
      expect_faker_response('Faker::Food', 'ingredient', skip_data_empty: true)
      get '/faker/foods/ingredient'
      expect_faker_response('Faker::Food', 'ingredient', skip_data_empty: true)
      get '/faker/foods/ingredients'
      expect_faker_response('Faker::Food', 'ingredient', skip_data_empty: true)
    end

    def expect_faker_response(mod = nil, method = nil, opt = {})
      expect(last_response.status).must_equal 200
      expect(last_response.headers['Content-Type']).must_equal 'application/json'
      expect(response_json['data']).wont_be_empty unless opt[:skip_data_empty]
      expect(response_json['data'].class).must_equal(Array)
      expect(response_json['module']).must_equal(mod) if mod
      expect(response_json['method']).must_equal(method) if method
    end
  end

  def response_json
    JSON.parse(last_response.body)
  end
end
