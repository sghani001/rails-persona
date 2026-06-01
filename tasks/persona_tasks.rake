namespace :persona do
  desc "Prune old persona events"
  task prune: :environment do
    days = Persona.configuration.auto_prune_after_days || 90
    Persona::Pruner.prune_older_than(days)
    puts "Pruned persona events older than #{days} days"
  end
end