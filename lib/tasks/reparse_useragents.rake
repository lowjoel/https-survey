namespace :db do
  desc 'Re-parse all user agent strings in database'

  task reparse_useragents: :environment do
    ClientSample.transaction do
      ClientSample.all.each do |s|
        s.save
      end
    end
  end
end
