# frozen_string_literal: true

# Compares two locale files and detects missing translations.
class MissingTranslationDetector
  attr_reader :missing_translations

  # @params [String] base_file_name File name of the base locale is i.e. en-US
  # @params [String] target_file_name File name of a locale with missing translations is i.e. de
  def initialize(base_file_name, target_file_name)
    @base = yml_load base_file_name
    @target = yml_load target_file_name
    @missing_translations = []
  end

  # Detects missing translations within the target locale file
  # and stores it in "missing_translations".
  def detect(h = @base, keys = [])
    h.each_key do |key|
      key_path = keys.clone.push key

      if h[key].is_a?(Hash)
        detect h[key], key_path
      elsif blank?(key_path)
        missing_translations << OpenStruct.new(key_path: key_path,
                                               value: h[key])
      end
    end
  end

  # @returns [Boolean] true if missing translations are detected, otherwise false is returned.
  def missing_translations?
    !@missing_translations.empty?
  end

  private

  def blank?(keys)
    h = @target

    keys.each do |key|
      return true if !h.is_a?(Hash) || !h.key?(key)

      h = h[key]
    end

    h.nil?
  end

  def yml_load(file_name)
    h = YAML.load_file "#{Rails.root}/config/locales/#{file_name}.yml"
    h[h.keys.first]
  end
end
