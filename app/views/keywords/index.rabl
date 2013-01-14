collection @keywords
attributes :name

node('_links') { |m| {:self => keyword_path(m)} }