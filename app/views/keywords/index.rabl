collection @keywords
attributes :name, :response_text

node('_links') { |m| {:self => keyword_path(m)} }