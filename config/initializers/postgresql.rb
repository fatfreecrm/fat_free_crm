# Only needed for postgres-pr gem prior to version 0.6.3, for details see
# https://rails.lighthouseapp.com/projects/8994/tickets/3210-rails-postgres-issue
class PGconn

  def self.quote_ident(name)
    %("#{name}")
  end

end