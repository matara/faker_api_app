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

    def expect_faker_response(mod = nil, method = nil)
      expect(last_response.status).must_equal 200
      expect(last_response.headers['Content-Type']).must_equal 'application/json'
      expect(response_json['data']).wont_be_empty
      expect(response_json['data'].class).must_equal(Array)
      expect(response_json['module']).must_equal(mod) if mod
      expect(response_json['method']).must_equal(method) if method
    end
  end

  def response_json
    JSON.parse(last_response.body)
  end
end
