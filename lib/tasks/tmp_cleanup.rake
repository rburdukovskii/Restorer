namespace :tmp do
  desc "Удалить осиротевшие временные файлы обработки (AGE_HOURS=6, DRY_RUN=1)"
  task cleanup: :environment do
    ttl = Float(ENV.fetch("AGE_HOURS", "6")).hours
    dry = ENV["DRY_RUN"] == "1"

    result = TmpFilesCleanup.call(ttl: ttl, dry_run: dry)
    mb = (result.bytes.to_f / 1.megabyte).round(1)

    puts "#{dry ? 'Найдено' : 'Удалено'}: #{result.removed} файлов, #{mb} МБ"
    puts result.paths.first(20).join("\n") if dry
  end
end