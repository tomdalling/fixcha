require 'rails/all'
require 'paperclip'

Paperclip.options[:log] = false

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new("/dev/null")

class TestApp < Rails::Application
  secrets.secret_token    = "shhh dont tell anyone"
  secrets.secret_key_base = "shhh dont tell anyone too"

  config.logger = Logger.new("/dev/null")
  Rails.logger = config.logger

  routes.draw do
    post 'freddie' => 'freddie#index'
    match '*path' => Proc.new { raise "Wrong route" }, via: :all
  end
end

class Book < ActiveRecord::Base
  include Paperclip::Glue
  has_attached_file :text
  do_not_validate_attachment_file_type :text
end

class FreddieController < ActionController::Base
  def index
    content = File.read(params[:mercury].tempfile)
    render inline: content
  end
end

ActiveRecord::Schema.define do
  create_table :books, force: true do |t|
    t.attachment :text
  end
end

RSpec.describe "Rails and Paperclip integration" do
  include Fixcha::Methods
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it "can be used with Paperclip fields" do
    book = Book.new(text: fixcha('text/doctor.txt'))
    book.save!

    actual_content = Paperclip.io_adapters.for(book.text).read
    expect(actual_content).to eq("Why not Zoidberg?\n")
  end

  it "can be used as a Rack::Test parameter" do
    post '/freddie', mercury: fixcha('text/doctor.txt').to_upload
    expect(last_response.body).to eq("Why not Zoidberg?\n")
  end
end
