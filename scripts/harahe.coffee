# Description:
#   Get restaurant data from Gurunavi API
#
# Original:
#   https://gist.github.com/taketin/146d1412d11f5596770b
#
# Commands:
#   hubot harahe <address> - お店を検索
#   hubot osake <address>  - お店をキーワード「酒」で検索
#   hubot sake <address>   - お店をキーワード「酒」で検索
#   hubot lunch <address>  - ランチ営業ありのお店を検索
#   hubot oyatsu <address> - お店をキーワード「カフェ・スイーツ」で検索
#   hubot oyatu <address>  - お店をキーワード「カフェ・スイーツ」で検索

Client = require("node-rest-client").Client
client = new Client()
stringify = require("querystring").stringify

keyid       = 'f63ef9ccc4571d72debbe0120f2771d3'
apiHost     = 'https://api.gnavi.co.jp/RestSearchAPI/20150630/?'

sendRestaurant = (msg, query, prefix = '', budgetKey = 'budget') ->
  formatBudget = (budget) -> if typeof budget == 'string' then "#{budget}円" else "不明"
  request = apiHost + stringify(query)
  msg.send request

  client.get request, (data, res) ->
    response = JSON.parse(data)
    if response['error']
      msg.reply response['error']['message']
      return

    page = Math.floor Math.random() * Math.min(response['total_hit_count'], response['hit_per_page'])
    restaurant = if response['total_hit_count'] == '1' then response['rest'] else response['rest'][page]
    msg.send """
    #{prefix}#{restaurant['name']}
    カテゴリ: #{restaurant['category']}
    平均予算: #{formatBudget(restaurant[budgetKey])}
    住所: #{restaurant['address']}
    #{restaurant['url']}
    """

module.exports = (robot) ->
  robot.respond /HARAHE ?(.*)$/i, (msg) ->
    query = {
      keyid: keyid
      hit_per_page: 20
      address: msg.match[1].trim()
      format: 'json'
    }
    sendRestaurant(msg, query)

  robot.respond /GURU ?(.*)$/i, (msg) ->
    fw = msg.match[1]
    fwf = fw.replace(/\s+/, ",")
    params = {
      keyid: keyid
      hit_per_page: 20
      freeword: fwf
      format: 'json'
    }
    
    robot.http(apiHost).query(params).get() (err, res, body) ->
      return res.send "Encountered an error :( #{err}" if err
      response = JSON.parse(body)
      #msg.send body
      formatBudget = (budget) -> if typeof budget == 'string' then "#{budget}円" else "不明"
      page = Math.floor Math.random() * Math.min(response['total_hit_count'], response['hit_per_page'])
      restaurant = if response['total_hit_count'] == '1' then response['rest'] else response['rest'][page]
      msg.send """
      #{restaurant['name']}
      カテゴリ: #{restaurant['category']}
      平均予算: #{formatBudget(restaurant['budget'])}
      住所: #{restaurant['address']}
      #{restaurant['url']}
      """
      
      #msg.send "#{body.result}"
      
      #sendRestaurant(msg, query, ':sake:')

  robot.respond /LUNCH ?(.*)$/i, (msg) ->
    query = {
     keyid: keyid
      hit_per_page: 20
      address: msg.match[1].trim()
      lunch: 1
      format: 'json'
    }
    sendRestaurant(msg, query, '', 'lunch')

  robot.respond /OYATS?U ?(.*)$/i, (msg) ->
    query = {
      keyid: keyid
      hit_per_page: 20
      address: msg.match[1].trim()
      freeword: 'カフェ・スイーツ'
      format: 'json'
    }
    sendRestaurant(msg, query, ':cake:')