#
# By default, HashMap's to_json/as_json comes from Enumerable, which converts the map to an array of key/value pairs.
# This initializer tells as_json/to_json to use the hash value of the HashMap.
#

if defined?(Java)

  Java::JavaUtil::HashMap.delegate :as_json, to: :to_hash

end