# Keeps all secrets, both in the YAML file and in memory.
# Manages two way encryption between them as well.
class Secrets < Settingslogic
  source "#{Rails.root}/config/secrets.yml"
  namespace Rails.env
end
