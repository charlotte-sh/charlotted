ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'charlotted.db'
)

unless ActiveRecord::Base.connection.table_exists?(:sessions)
  ActiveRecord::Base.connection.create_table :sessions, force: true do |t|
    t.string :username
    t.string :address
  end
end
