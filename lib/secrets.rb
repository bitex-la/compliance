# Keeps all secrets, both in the YAML file and in memory.
# Manages two way encryption between them as well.
class Secrets < Settingslogic
  source "#{Rails.root}/config/secrets.yml"
  namespace Rails.env

  # The prompt_on variable stores a path for a linux pipe where the
  # strong secret is expected to be read from.
  # The pipe itself is created by this process.
  # Setting this value signals that this process has access to the memory secret
  cattr_accessor :prompt_on

  cattr_accessor :memory_secret

  PROMPT_MUTEX = Mutex.new
  def self.with_memory_secret(&blk)
    raise NoAccessToMemorySecret.new unless can_use_memory_secret?

    return blk.call(memory_secret) if memory_secret

    PROMPT_MUTEX.synchronize do
      # Check for memory_secret  again once mutex has been obtained,
      # If we were kept waiting, whoever kept us waiting may have set it.
      unless memory_secret
        `rm -f #{prompt_on}`
        `mkfifo #{prompt_on}`
        Rails.logger.info "Waiting for $ echo supersecret > #{prompt_on}"
        self.memory_secret = open(prompt_on, "r+").gets.strip
        Rails.logger.info "Got password on #{prompt_on}"
        `rm -f #{prompt_on}`
      end
    end

    blk.call(memory_secret)
  end

  def self.can_use_memory_secret?
    memory_secret || prompt_on
  end

  def self.memory_secret_encrypt(plain_text)
    # To obfuscate a bit more, and to write a shorter testing secret
    # we use it multiplied 10 times.
    with_memory_secret{|s| cipher(:encrypt, s*10, plain_text) }
  end

  def self.memory_secret_decrypt(encrypted)
    # To obfuscate a bit more, and to write a shorter testing secret
    # we use it multiplied 10 times.
    with_memory_secret{|s| cipher(:decrypt, s*10, encrypted) }
  end

  def self.encrypt(plain_text)
    cipher(:encrypt, secret_key_base, plain_text)
  end

  def self.decrypt(encrypted)
    cipher(:decrypt, secret_key_base, encrypted)
  end

  def self.cipher(action, key, plain_text)
    c = OpenSSL::Cipher::AES256.new(:CBC)
    c.send(action)
    c.key = key
    c.iv = Secrets.cipher_iv
    c.update(plain_text) + c.final
  end

  class Coder
    def self.load(value)
      value.nil? ? {} : JSON.load(Secrets.decrypt(value))
    end

    def self.dump(value)
      Secrets.encrypt(JSON.dump(value))
    end
  end

  class CoderWithMemorySecret
    def self.load(value)
      return {encrypted: value} unless Secrets.can_use_memory_secret?
      value.nil? ? {} : JSON.load(Secrets.memory_secret_decrypt(value))
    end

    def self.dump(value)
      return value[:encrypted] unless Secrets.can_use_memory_secret?
      Secrets.memory_secret_encrypt(JSON.dump(value))
    end
  end

  class NoAccessToMemorySecret < StandardError; end
end
