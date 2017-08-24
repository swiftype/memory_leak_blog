require 'zendesk_api'
require 'webmock'
include WebMock::API
WebMock.enable!

BASE_URL = 'https://swiftypeblog.zendesk.com/api/v2'
NUM_TOTAL_TICKETS = 30_000
PER_PAGE = 100
NUM_PAGES = NUM_TOTAL_TICKETS / PER_PAGE

fake_ticket = {
  'url' => 'https://company.zendesk.com/api/v2/tickets/35436.json',
  'external_id' => nil,
  'via' => { 'channel' => 'email', 'source' => { 'from' => { 'address' => 'sender@domain.com', 'name' => 'Sender' }, 'to' => { 'name' => 'Recipient', 'address' => 'recipient@domain.com' }, 'rel' => nil } },
  'created_at' => '2014-01-09 21:58:02 UTC',
  'updated_at' => '2014-01-15 15:35:39 UTC',
  'type' => 'question',
  'subject' => 'A very descriptive subject that is easy to understand regarding some problem.',
  'raw_subject' => 'A very descriptive subject that is easy to understand regarding some problem.',
  'description' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod ultricies nisi, nec fringilla purus laoreet et. Ut et dignissim lectus, sit amet tincidunt sapien. Donec massa urna, malesuada et mauris eu, aliquam finibus erat. Suspendisse rutrum nunc vel felis hendrerit, ac dignissim quam rhoncus. Quisque ac tempus purus. Aliquam lectus sem, scelerisque ornare diam ac, fermentum venenatis felis. Sed iaculis libero sed tortor luctus, vel pretium dui faucibus. Aliquam rhoncus condimentum tincidunt. Ut varius, velit quis accumsan volutpat, felis sapien finibus orci, et blandit nulla felis sodales orci. Morbi nec tortor urna. Cras vitae diam suscipit ex volutpat tincidunt. Nunc bibendum vel augue a aliquam.',
  'priority' => 'normal',
  'status' => 'hold',
  'recipient' => 'recipient@domain.com',
  'requester_id' => 99999,
  'submitter_id' => 99999,
  'assignee_id' => nil,
  'organization_id' => nil,
  'group_id' => 99999,
  'collaborator_ids' => [],
  'forum_topic_id' => nil,
  'problem_id' => nil,
  'has_incidents' => false,
  'is_public' => true,
  'due_at' => nil,
  'tags' => ['paying_customer', 'some_tag'],
  'custom_fields' => [
    { 'id' => 1, 'value' => nil },
    { 'id' => 2, 'value' => nil },
    { 'id' => 3, 'value' => nil },
    { 'id' => 4, 'value' => nil },
    { 'id' => 5, 'value' => nil }
  ]
}

WebMock.stub_request(:get, /#{BASE_URL}\/tickets/).to_return do |request|
  page = Integer(request.uri.query_values['page'])
  offset = page * PER_PAGE

  if page < NUM_PAGES
    {
      :status => 200,
      :body => JSON.dump({
        :tickets => (offset..offset + PER_PAGE).map do |id|
          fake_ticket.dup.tap { |x| x['id'] = id }
        end,
        :next_page => page < NUM_PAGES ? page + 1 : nil
      }),
      :headers => { 'Content-Type' => 'application/json', 'Etag' => 'Some etag' },
    }
  else
    {
      :status => 200,
      :body => JSON.dump({ :tickets => [] }),
      :headers => { 'Content-Type' => 'application/json' }
    }
  end
end


zendesk_client = ZendeskAPI::Client.new do |client|
  client.access_token = 'foo'
  client.url = BASE_URL
end

ticket_count = 0
zendesk_client.tickets.page(0).all! do |ticket|
  ticket_count += 1
  puts ticket_count if ticket_count % 10000 == 0
  next
end
