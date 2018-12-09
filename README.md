Fixcha
======

Fixture helpers for RSpec/Paperclip/Rails/Rack::Test.

```ruby
#
# Rack::Test
#
RSpec.describe '/whatever' do
  it 'does the thing' do
    # NO
    post '/whatever', {
      thing: fixture_file_upload(Rails.root.join('files/spongebob.png'), 'image/png')
    }


    # YES
    post '/whatever', {
      thing: fixcha('files/spongebob.png').to_upload # content type is inferred
    }
  end
end
```

```ruby
#
# Paperclip
#

# NO
FactoryBot.create(:my_model,
  paperclip_attr: File.open(Rails.root.join('files/spongebob.png'))
)

# YES
FactoryBot.create(:my_model,
  paperclip_attr: fixcha('files/spongebob.png')
)
```
