require 'open-uri'
require 'json'

class WordGameController < ApplicationController
  def game
    @grid = generate_grid(20)
    @start_time = Time.now.to_i
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid]
    @end_time = Time.now.to_i
    @start_time = params[:start_time].to_i


    run_game(@attempt, @grid, @start_time, @end_time)
    time_taken = @end_time - @start_time
    @score = compute_score(@attempt, time_taken)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def included?(guess, grid)
    guess.split.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : @attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(@attempt)
    result[:score], result[:message] = score_and_message(
      @attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(@attempt.upcase, grid)
      if translation
        score = compute_score(@attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "YOUR_SYSTRAN_API_KEY"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end


end

#   Specs

# This is how your game should work: we only give you the routing structurem, that's your call to generate the relevant controller, actions and views.

# GET '/game': render the page with a new random grid of words, and the HTML form to write your guess just below the word-grid.

# GET '/score' should compute and display your score..

# Further suggestions

# To submit a parameter through a form without displaying the corresponding input, you can use a hidden input field <input type="hidden">!
# end
