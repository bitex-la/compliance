module Util
  class NormalizeIdentifications
    def self.chile_tax_id_regx
      '^0-9k-kK-K'
    end

    def self.argentina_tax_id_regx
      '^0-9'
    end

    def self.normalize_tax_id(tax_id, regx)
      result = tax_id&.delete(regx)
      return if result&.empty?
      result
    end
  end
end
