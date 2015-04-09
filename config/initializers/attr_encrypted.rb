# Key to use for attr_encrypted.
# Provide via environment variable for production environments.
# Othwerwise a default is provided.
ActiveRecord::Base.attr_encrypted_options[:key] = ENV['ATTR_ENCRYPTED_KEY'] || '10536b708d56b7219a0fae56c33a5ea77615d212cc75864885ca52cc9051d2062b2cf3f4b79319864cfba503c3f278ba918a5c82c34e599b84d4e9f394ec99a7'
