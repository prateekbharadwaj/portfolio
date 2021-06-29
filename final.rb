require 'uri'
require 'net/http'
require 'json'

$i = 0

class Fetch

  def use(uri)   
    apihost = URI('https://fourtytwowords.herokuapp.com')
	uri = apihost+uri
	params = { :api_key => 'fb8007781a73a8884e3821dc8f330cf2949b422d2a4be2bac9f1d5def50213d48f04cf2869255230d8e5adc4bee08ed27035a7a65745b5184b37848e93a691c099b93b1b072f24ad7908352ed10947e3' }
	uri.query = URI.encode_www_form(params)
	res = Net::HTTP.get_response(uri)
	if res.is_a?(Net::HTTPSuccess)
		return JSON.parse(res.body)
	end
  end

  def line()
    85.times do
	  print "_ "
    end
    puts ""
  end
end 

class Dict < Fetch

  def word_definitions(word)
	definition = "/word/#{word}/definitions"
	obj = use(definition)
	$i=0 
	while $i < 10  do
      print "#{$i+1} :" 
	  puts obj[$i]["text"]  
	  $i +=1
	end    
  end

  def get_synonyms(word)
	synant = "/word/#{word}/relatedWords"
	obj = use(synant)
	toggle = 0
	if obj[0]["relationshipType"] == "antonym"
      toggle = 1
	end
	p = obj[toggle]["words"].size
	$i=0 
	while $i < p  do
	  print "#{$i+1} :" 
	  puts obj[toggle]["words"][$i]
	  $i +=1
	end
  end

  def get_antonyms(word)
	synant = "/word/#{word}/relatedWords"
	obj = use(synant)
	if obj[0]["relationshipType"] == "antonym"
	  p = obj[0]["words"].size
	  $i=0 
	  while $i < p  do
		print "#{$i+1} :" 
		puts obj[0]["words"][$i]
		$i +=1
	  end
	  
	else
	  puts "No Antonyms are Present"
	end
  end

  def get_examples(word)
	name = Array.new
	example = "/word/#{word}/examples"
	obj = use(example)
	$i=0 
	while $i < 5  do
	  print "#{$i+1} :" 
	  temp = obj["examples"][$i]["text"]
	  puts obj["examples"][$i]["text"]
	  name.append(temp)
      $i +=1
	end
  end

  def full_details(word)
	line()
	puts "Word Definations"
	word_definitions(word)
	line()
	puts "Word Synonyms"
	get_synonyms(word)
	line()
	puts "Word Antonyms"
	get_antonyms(word)
	line()
	puts "Word Examples"
	get_examples(word)
	line()
	puts ""
  end

  def word_of_the_day
	day_word = "/words/randomWord"
	obj = use(day_word)
	word = obj['word']
	puts "The Word Of The Day is : #{word}"
	full_details(word)
  end
end

class Game < Fetch
  def initialize
	@word = ""
	#@lives = 3
	@word_teaser = ""
	@score=0
	@@s= "NEW GAME" 
	@ex = Array.new
	@defi = Array.new
	@relaw = Array.new
  end

  def random_word
	@relaw.clear
	@defi.clear
	@ex.clear
	day_word = "/words/randomWord"
	obj1 = use(day_word)
	puts obj1['word']
	@word = obj1['word']
	definition = "/word/#{@word}/definitions"
	obj2 = use(definition)
	print "Meaning of the Word: "
	puts obj2[0]["text"]
  end

  def apidef
	if @defi.empty?
	  definition = "/word/#{@word}/definitions"
	  obj = use(definition)
	  $i=1 
	  while $i < 10  do
	    temp = obj[$i]["text"]  
	    @defi.append(temp)
	    $i +=1
	  end
	  puts obj[1]["text"]
	else
		puts @defi.pop
	end
  end

  def apiex
	if @ex.empty?
	  example = "/word/#{@word}/examples"
	  obj = use(example)
	  $i=1 
	  while $i < 5  do
	    temp = obj["examples"][$i]["text"]
	    @ex.append(temp)
	    $i +=1
	  end
	  puts obj["examples"][0]["text"]
	else
	  puts @ex.pop
	end
  end

  def apirelated
	if @relaw.empty?
	  relatedWord = "/word/#{@word}/relatedWords"
	  obj = use(relatedWord)
	  toggle = 0
	  if obj[0]["relationshipType"] == "antonym"
	    toggle = 1
	  end
	  p = obj[toggle]["words"].size
	  $i=0 
	  while $i < p  do
	    temp = obj[toggle]["words"][$i]
	    @relaw.append(temp)
		$i +=1
	  end
	  puts obj[0]["words"][0]
	else
	puts @relaw.pop
	end
  end

  def jumbled(str)
	s = str.split(//).sort_by { rand }.join('')
	s =~ /[A-Z]/ && s =~ /[a-z]/ ? s.capitalize : s
	puts s
  end

  def display
	line()
	puts "Thank You For Playing"
	if @score<0
	  @score = 0
	end
	puts "Your Final Score is : #{@score}"
  end

  def make_guess 
	game = true
    if game == true
	  puts "Guess the word"
	  guess = STDIN.gets.chomp
	  good_guess = @word.eql?(guess)
	  if good_guess 
 	    puts"You Are Correct"
	    @score +=10
	    puts "Score  : #{@score}"
		#@lives = 3
	    begin_new
	  else 
	    #@lives -= 1
	    puts "Sorry... Please Try again!"
		@score -=2
		if @score<0
		  @score = 0
		end
		puts "Score  : #{@score}"
		puts "1.Try Again 2.Hint 3.Skip 4.Exit"
		nextw = STDIN.gets.chomp
		case nextw
		when "1"
		  puts "Score  : #{@score}"
		  make_guess
		when "2"
		  puts "What Hint do you want 1. Other Definations 2. Examples 3.Related Word 4.Jumbled Word 5. Exit"
		  @score -=3
		  if @score<0
		    @score = 0
		  end
		  puts "Score  : #{@score}"
		  hint_type = STDIN.gets.chomp
		  case hint_type
		  when "1"
		    apidef
			make_guess
		  when "2"
		    apiex
			make_guess
		  when "3"
		    apirelated
		    make_guess
		  when "4"
		    jumbled(@word)
		    make_guess
		  when "5"
			display
			game = false
			@@s= "NEW GAME" 
		  else
			puts "Invalid Input"
			#@lives = 3
			@@s= "NEW GAME" 
		  end
		when "3"
		  @score -=4
		  if @score<0
		    @score = 0
		  end
		  puts "Score  : #{@score}"
		  begin_new
		when "4"
		  display
		  @@s= "NEW GAME" 
		  game = false
		else 
		  puts "Invalid Input"
		end
	  end
	end
  end

  def print_instructions
	line()
	puts "INSTRUCTIONS"
	puts "Each correct answer gives 10 points."
	puts "Each hint reduces 3 point."
	puts "Each wrong try reduces 2 points."
	puts "Skip reduces 4 points."
	line()
  end

  def begin_new
    line()
	puts @@s
	if(@@s == "NEW GAME")
	  print_instructions
	  @@s= "TRY NEXT"
	end
	random_word
	puts "Score  : #{@score}"
	make_guess
  end
end

game = Game.new
a=Dict.new
input = ARGV
if input.length != 0
  case input[0]
  when "def"
    word = input[1]
    a.word_definitions(word)
  when "syn"
	word = input[1]
	a.get_synonyms(word)
  when "ant"
    word = input[1]
    a.get_antonyms(word)
  when "ex"
    word = input[1]
    a.get_examples(word)
  when "play"
    game.begin_new
  when input[0]
    word = input[0]
    a.full_details(word)
  end
else
  a.word_of_the_day	
end


  






