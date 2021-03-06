require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db() 
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

def check_parameters_empty hh
  return hh.select {|key,_| params[key]  == ""}.values.join(", ")
end

def is_barber_exists? db, name
  db.execute('SELECT * FROM Barbers WHERE Name=?', [name]).length > 0
end

def seed_db db, barbers

  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute 'INSERT INTO Barbers (Name) VALUES (?)', [barber]
    end
  end

end

def get_barbers
  db = get_db
  db.execute 'SELECT * FROM Barbers ORDER BY Name '
end

configure do

  db = get_db()
  db.execute 'CREATE TABLE IF NOT EXISTS
  "Users"
  (
    "Id" INTEGER PRIMARY KEY AUTOINCREMENT, 
    "Username" VARCHAR, 
    "Phone" VARCHAR, 
    "Datestamp" VARCHAR, 
    "Barber" VARCHAR, 
    "Color" VARCHAR
  )'

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Barbers"
  (
    "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "Name" VARCHAR
  )'

  seed_db db, ['Опасный', 'Стригун', 'Оболванщик']
 
end

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
  @error = 'Внимание ошибка!'
  erb :about
end

get '/visit' do
  
  @results =  get_barbers
  @barber = 1

  erb :visit

end

get '/showusers' do
  
  db = get_db
  
  @results =  db.execute 'SELECT * FROM Users ORDER BY Id desc' 
  
  erb :showusers

end

post '/visit' do
  
  @username = params[:username] 
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  @color = params[:color]
  
  hh = {:username => 'Введите имя',
        phone: 'Введите телефон',
        datetime: 'Введите дату и время'}
  
  #@error = ''
  #params.each do |key, value|
  #  #Если параметр пуст
   # if params[key] == ''
   #   @error = @error + "key - #{key}; value - #{value}"
  #  end
  #end
  
  @my_error = check_parameters_empty hh

  if @my_error != ''
    @error = @my_error

    @results =  get_barbers

    return erb :visit
  end

  running_dir = File.dirname(__FILE__)
  running_dir = Dir.pwd if (running_dir == '.')
  f = File.open running_dir + '/public/users.txt', 'a:windows-1251'
  f.write "User: #{@username}, phone: #{@phone}, datetime: #{@datetime}, employee: #{@barber},
    color: #{@color}. \n"
  f.close
  
  db = get_db
  db.execute 'INSERT INTO 
    Users
    (
      Username,
      Phone,
      Datestamp,
      Barber,
      Color
    )
    VALUES ( ?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]

  erb "Вы записались! #{@username} спасибо что выбрали нас! 
    Ждем вас #{@datetime}. Ваш телефон #{@phone}. Ваш мастер #{@barber}. 
    Выбранный цвет покраски #{@color}."
end

get '/showusers' do
  erb "HW"
end


