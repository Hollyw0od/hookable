require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)
Dotenv.load

require "./hook_delivery"

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')
end

post "/" do
  headers = {
    "X-GitHub-Event"    => request.env["X-Github-Event"],
    "X-GitHub-Delivery" => request.env["X-Github-Delivery"],
    "X-Hub-Signature"   => request.env["X-Hub-Signature"]
  }.to_json
  payload = request.body.read

  HookDelivery.create(
    :payload => payload,
    :headers => headers
  )

  status 200
end

get "/" do
  @hook_deliveries = HookDelivery.all
  puts @hook_deliveries.inspect
  erb :index
end

delete "/" do
  HookDelivery.destroy_all
  status 200
end

####
# Simple presentation helper
####

helpers do
  def seconds_ago(number)
    if number == 1
      "#{number} second ago"
    else
      "#{number} seconds ago"
    end
  end
end
