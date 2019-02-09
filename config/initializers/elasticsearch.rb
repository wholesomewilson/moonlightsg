if Rails.env == "production"
  Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['E_ELASTIC_URL']
  Searchkick.client = Elasticsearch::Client.new(hosts: ENV['E_ELASTIC_URL'], retry_on_failure: true, transport_options: {request: {timeout: 250} })
else
  Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['E_ELASTIC_URL']
  Searchkick.client = Elasticsearch::Client.new(hosts: ENV['E_ELASTIC_URL'], retry_on_failure: true, transport_options: {request: {timeout: 250} })
end
