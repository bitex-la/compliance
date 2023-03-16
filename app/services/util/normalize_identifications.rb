module Util
  class NormalizeIdentifications
    def self.chile_tax_id_regx
      '^0-9k-kK-K'
    end

    def self.argentina_tax_id_regx
      '^0-9'
    end
  end
end
